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
        return try! Realm(configuration: config)
    }()
    
    func printRealmFileURL() {
        print(localRealm.configuration.fileURL?.path)
    }
    
    func fetchAreaCode(completionHandler: @escaping (Results<AreaCode>) -> ()) {
        
        let codeList = localRealm.objects(AreaCode.self)
        
        if codeList.isEmpty {
            
            APIManager.shared.requestAreaCode { [weak self] list in
                
                list.forEach { code in
                    do {
                        try self?.localRealm.write({
                            self?.localRealm.add(code)
                        })
                    } catch {
                        print("지역 코드 추가 에러")
                    }
                }
                
                if let codeList = self?.localRealm.objects(AreaCode.self) {
                    completionHandler(codeList)
                }
            }
        } else {
            completionHandler(codeList)
        }
        
    }
    
    func fetchNearPlace(location: Circle, failureHandler: @escaping () -> (), completionHandler: @escaping (_ newCount: Int, _ placeList: [CommonPlaceInfo]) -> ()) {
    
        APIManager.shared.requestNearPlace(pos: location, failureHandler: failureHandler) { [weak self] placeList in
            
            var count = 0
            
            let newInfoList = placeList.sorted { left, right in
                left.dist < right.dist
            }.map { (info) -> CommonPlaceInfo in
                
                if let place = self?.localRealm.object(ofType: CommonPlaceInfo.self, forPrimaryKey: info.contentId) {
                    do {
                        try self?.localRealm.write {
                            place.dist = info.dist
                        }
                    } catch { print("데이터 수정 오류") }
                    return place
                } else {
                    count += 1
                    do {
                        try self?.localRealm.write {
                            self?.localRealm.add(info)
                        }
                    } catch { print("데이터 추가 오류") }
                    return info
                }
            }
            
            completionHandler(count, newInfoList)
            
        }
        
        
    }
    
    /*
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
    */
    
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
    
    /*
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
    */
    
    /*
    func registerPlaceInfo<T: Object>(info: T) {
        
        do {
            try localRealm.write({
                localRealm.add(info)
            })
        } catch {
            print("장소 정보 등록 실패")
        }
    }
    */
    
    /*
    func isExist<T:Object>(infoType: T.Type, contentId: Int) -> Bool {
        return localRealm.object(ofType: infoType, forPrimaryKey: contentId) == nil ? false : true
    }
    */
    
    func loadPlaceInfo<T: Object>(infoType: T.Type, contentId: Int) -> T? {
        return localRealm.object(ofType: infoType, forPrimaryKey: contentId)
    }
     
    
    func fetchPlaces<T: Object>(type: T.Type) -> Results<T>{
        localRealm.objects(type)
    }
    
    func fetchPlaceIntro(place: CommonPlaceInfo, completionHandler: @escaping () -> ()) {
        
        if place.intro == nil {
            
            APIManager.shared.requestPlaceIntro(contentId: place.contentId) { [weak self] data in
                print("장소 소개 데이터 잘 받았다✌️✌️✌️✌️✌️")
                do {
                    try self?.localRealm.write({
                        place.intro = data
                    })
                    completionHandler()
                } catch {
                    print("장소 소개 데이터 쓰기 실패")
                }
                
            }
            
        } else {
            completionHandler()
        }
    }
    
    func fetchPlaceDetail<T: Information>(type: T.Type, contentId: Int, contentType: ContentType, completionHandler: @escaping (T) -> ()) {
        
        if let place = localRealm.object(ofType: type, forPrimaryKey: contentId) {
            completionHandler(place)
        } else {
            
            APIManager.shared.requestDetailPlaceInfo(contentId: contentId, contentType: contentType) { [weak self] (data: T) in
                print("장소 세부 데이터 잘 받았다🫶🫶🫶🫶🫶🫶")
                do {
                    try self?.localRealm.write({
                        self?.localRealm.add(data)
                    })
                    completionHandler(data)
                } catch {
                    print("장소 세부 데이터 쓰기 실패")
                }
                
            }
        }
        
    }
    
    func fetchPlaceExtra (contentId: Int, contentType: ContentType, completionHandler: @escaping (ExtraPlaceInfo) -> ()) {
        
        if let place = localRealm.object(ofType: ExtraPlaceInfo.self, forPrimaryKey: contentId) {
            completionHandler(place)
        } else {
            
            APIManager.shared.requestExtraPlaceInfo(contentId: contentId, contentType: contentType) { [weak self] (data: [ExtraPlaceElement]) in
                print("장소 추가 데이터 잘 받았다👏👏👏👏👏👏")
                do {
                    let extra = ExtraPlaceInfo(id: contentId, infoList: data)
                    try self?.localRealm.write({
                        self?.localRealm.add(extra)
                    })
                    completionHandler(extra)
                } catch {
                    print("장소 추가 데이터 쓰기 실패")
                }
                
            }
        }
        
    }
    
    func fetchPlaceImages (contentId: Int, completionHandler: @escaping ([PlaceImage]) -> ()) {
        
        if let image = localRealm.object(ofType: PlaceImageInfo.self, forPrimaryKey: contentId) {
            completionHandler(image.images)
        } else {
            
            APIManager.shared.requestDetailImages(contentId: contentId) { [weak self] images in
                print("장소 이미지 데이터 잘 받았다👻👻👻👻👻")
                do {
                    let image = PlaceImageInfo(id: contentId, imageList: images)
                    try self?.localRealm.write({
                        self?.localRealm.add(image)
                    })
                    completionHandler(images)
                } catch {
                    print("장소 이미지 데이터 쓰기 실패")
                }
                
            }
        }
        
    }
    
}
