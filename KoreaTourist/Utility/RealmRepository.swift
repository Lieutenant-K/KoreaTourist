//
//  RealmRepository.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2022/09/21.
//

import UIKit
import RealmSwift

class RealmRepository {
    
    private let localRealm: Realm = {
        var config = Realm.Configuration.defaultConfiguration
        config.deleteRealmIfMigrationNeeded = true
        
        return try! Realm(configuration: config)
    }()
    
    func printRealmFileURL() {
        print(localRealm.configuration.fileURL?.path)
    }
    
    func registerPlaces(using infoList: [CommonPlaceInfo]) -> (newCount: Int, fetchedInfo: [CommonPlaceInfo]) {
        
        var count = 0
        
        let newInfoList = infoList.map { (info) -> CommonPlaceInfo in
            
            if let place = localRealm.object(ofType: CommonPlaceInfo.self, forPrimaryKey: info.contentId) {
                do {
                    try localRealm.write {
                        place.dist = info.dist
                    }
                } catch {
                    print("데이터 수정 오류")
                }
                return place
            } else {
                count += 1
                do {
                    try localRealm.write {
                        localRealm.add(info)
                    }
                } catch {
                    print("데이터 추가 오류")
                }
                return info
            }
        }
        
        return (count, newInfoList)
        
    }
    
    func discoverPlace(with contentId: Int) {
        
        guard let place = localRealm.object(ofType: CommonPlaceInfo.self, forPrimaryKey: contentId) else { return }
        
        do {
            try localRealm.write({
                place.discoverDate = Date()
            })
        } catch {
            print("장소 발견 실패")
        }
    }
    
    func addPlaceIntro(with to: CommonPlaceInfo, using from: Intro) {
        
        do {
            try localRealm.write {
                to.intro = from
            }
        } catch {
            
        }
        
        /*
        do {
            try localRealm.write({
                to.homepage = from.homepage
                to.overview = from.overview
                to.tel = from.tel
                to.telName = from.telName
                to.zipcode = from.zipcode
            })
        } catch {
            print("장소 업데이트 실패")
        }
        */
        
    }
    
    func registerPlaceInfo<T: Object>(info: T) {
        
        do {
            try localRealm.write({
                localRealm.add(info)
            })
        } catch {
            print("장소 정보 등록 실패")
        }
    }
    
    func isExist<T:Object>(infoType: T.Type, contentId: Int) -> Bool {
        return localRealm.object(ofType: infoType, forPrimaryKey: contentId) == nil ? false : true
    }
    
    func loadPlaceInfo<T: Object>(infoType: T.Type, contentId: Int) -> T? {
        return localRealm.object(ofType: infoType, forPrimaryKey: contentId)
    }
    
    func fetchPlaces<T: Object>(type: T.Type) -> Results<T>{
        localRealm.objects(type)
    }
    
}
