//
//  UserPlaceRepository.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2023/05/23.
//

import Foundation

import RealmSwift
import Combine

/// 장소 데이터베이스에 접근하여 로직을 수행하는 객체
final class CommonUserRepository {
    private let dbService = try? Realm()
    
    init() {
        let url = self.dbService?.configuration.fileURL
        print(url?.absoluteString)
        do {
            try self.dbService?.write {
                self.dbService?.deleteAll()
            }
        } catch {
            print("초기화 시 모든 데이터 삭제 실패")
        }
    }
    
    /// 새로운 장소를 DB에 저장하고 저장된 장소를 불러오는 메서드
    /// - Parameter places: DB에 저장하고자 하는 장소 객체의 배열
    /// - Returns: DB에 저장된 장소 객체 배열
    /// - DB에 성공적으로 저장되었다면, 인자로 넘겨준 장소 객체 배열과 반환값은 동일하다.
    func updatePlaces(places: [CommonPlaceInfo]) -> [CommonPlaceInfo] {
        places.compactMap {
            if self.isExist(contentId: $0.contentId, type: CommonPlaceInfo.self) {
                return self.replace(with: $0)
            }
            else {
                return self.add(place: $0)
            }
        }
    }
    
    func discoverPlace(with contentId: Int, completion: () -> ()) {
        if let place = self.dbService?.object(ofType: CommonPlaceInfo.self, forPrimaryKey: contentId) {
            do {
                try self.dbService?.write {
                    place.discoverDate = Date()
                    completion()
                }
            } catch {
                print(error)
            }
        }
    }
    
    func isExist(contentId: Int, type: Object.Type) -> Bool {
        self.dbService?.object(ofType: type, forPrimaryKey: contentId) != nil
    }
    
    func updateIntro(target place: CommonPlaceInfo, with: Intro) {
        do {
            try self.dbService?.write {
                place.intro = with
            }
        } catch {
            print(error)
        }
    }
    
    func save(object: Object) {
        do {
            try self.dbService?.write {
                self.dbService?.add(object)
            }
        } catch {
            print(error)
        }
    }
    
    func load<T: Object>(type: T.Type, contentId: Int) -> T? {
        self.dbService?.object(ofType: type, forPrimaryKey: contentId)
    }
}

extension CommonUserRepository {
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
        guard let object = self.dbService?.object(ofType: CommonPlaceInfo.self, forPrimaryKey: with.contentId) else { return nil }
        
        do {
            try self.dbService?.write {
                object.dist = with.dist
            }
        } catch {
            print(error)
            return nil
        }
        return object
    }
}
