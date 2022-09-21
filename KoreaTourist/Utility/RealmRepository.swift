//
//  RealmRepository.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2022/09/21.
//

import UIKit
import RealmSwift

class RealmRepository {
    
    let localRealm: Realm = {
        var config = Realm.Configuration.defaultConfiguration
        config.deleteRealmIfMigrationNeeded = true
        
        return try! Realm(configuration: config)
    }()
    
    func printRealmFileURL() {
        print(localRealm.configuration.fileURL?.path)
    }
    
    func addNewPlace(using infoList: [CommonPlaceInfo]) -> Int {
        
        var count = 0
        
        infoList.forEach { place in
            
            let isExist = localRealm.objects(CommonPlaceInfo.self).contains { $0.contentId == place.contentId
            }
            
            if !isExist {
                count += 1
                do {
                    try localRealm.write {
                        localRealm.add(place)
                    }
                } catch {
                    print("데이터 추가 오류")
                }
            } else {
                print("이미 존재함")
            }
        
        }
        
        return count
        
    }
    
    
}
