//
//  UserPlaceRepository.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2023/05/23.
//

import Foundation

import RealmSwift

final class UserPlaceRepository {
    private let dbService = try? Realm()
    
    func updatePlaces(places: [CommonPlaceInfo]) -> [CommonPlaceInfo] {
        places.compactMap {
            if self.isExist(place: $0) {
                return self.replace(with: $0)
            }
            else {
                return self.add(place: $0)
            }
        }
    }
}

extension UserPlaceRepository {
    private func add(place: CommonPlaceInfo) -> CommonPlaceInfo? {
        guard let service = self.dbService else { return nil }
        
        do {
            try service.write {
                service.add(place)
            }
        } catch {
            print(error)
            return nil
        }
        return place
    }
    
    private func replace(with: CommonPlaceInfo) -> CommonPlaceInfo? {
        guard let service = self.dbService, let object = service.object(ofType: CommonPlaceInfo.self, forPrimaryKey: with.contentId) else { return nil }
        
        do {
            try service.write {
                object.dist = with.dist
            }
        } catch {
            print(error)
            return nil
        }
        return object
    }
    
    private func isExist(place: CommonPlaceInfo) -> Bool {
        self.dbService?.object(ofType: CommonPlaceInfo.self, forPrimaryKey: place.contentId) != nil
    }
}
