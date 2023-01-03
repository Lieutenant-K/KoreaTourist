//
//  RealmRepository.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2022/09/21.
//

import UIKit
import RealmSwift

class RealmRepository: APIManager {
    private let localRealm: Realm = {
        var config = Realm.Configuration.defaultConfiguration
        return try! Realm(configuration: config)
    }()
    
    func fetchAreaCode(completionHandler: @escaping (Results<AreaCode>) -> ()) {
        let codeList = localRealm.objects(AreaCode.self)
        
        if codeList.isEmpty {
            requestData(router: .areaCode) { [weak self] (result: APIResult<[AreaCode]>) in
                switch result {
                case let .success(list):
                    list.forEach { self?.addObjcet(object: $0) }
                    
                    self?.fetchAreaCode(completionHandler: completionHandler)
                case let .apiError(response):
                    print(response.cmmMsgHeader.errMsg)
                default:
                    print("fetch area code error")
                }
            }
            return
        }
        
        completionHandler(codeList)
    }
    
    func fetchNearPlace(location: Circle, failureHandler: @escaping (FailureReason) -> (), completionHandler: @escaping (_ newCount: Int, _ placeList: [CommonPlaceInfo]) -> ()) {
    
        requestData(router: .location(location)) { [weak self] (result: APIResult<[CommonPlaceInfo]>) in
            switch result {
            case let .success(placeList):
                var count = 0
                let newInfoList = placeList
                    .sorted { $0.dist < $1.dist }
                    .compactMap { self?.addCommonPlace(info: $0, count: &count)}
                
                completionHandler(count, newInfoList)
            case let .apiError(response):
                failureHandler(.apiError(response))
            case .undefinedData:
                failureHandler(.noData)
            case let .failure(error):
                failureHandler(.networkError(error))
            }
        }
    }
    
    func discoverPlace(with contentId: Int) {
        if let place = localRealm.object(ofType: CommonPlaceInfo.self, forPrimaryKey: contentId) {
            updateDiscoverDate(place: place)
        }
    }
    
    
    func loadPlaceInfo<T: Object>(infoType: T.Type, contentId: Int) -> T? {
        localRealm.object(ofType: infoType, forPrimaryKey: contentId)
    }
     
    func loadPlaces<T: Object>(type: T.Type) -> Results<T> {
        localRealm.objects(type)
    }
    
    func fetchPlaceIntro(place: CommonPlaceInfo, completionHandler: @escaping () -> ()) {
        if place.intro == nil {
            requestData(router: .commonInfo(place.contentId)) { [weak self] (result:APIResult<[Intro]>) in
                print("장소 소개 데이터 잘 받았다✌️✌️✌️✌️✌️")
                
                switch result {
                case let .success(data):
                    guard let intro = data.first else { return }
                    
                    self?.addPlaceIntro(place: place, intro: intro)
                    completionHandler()
                default:
                    print("장소 소개 정보 가져오기 실패")
                }
            }
            return
        }
        
        completionHandler()
    }
    
    func fetchPlaceDetail<T: DetailInformation>(type: T.Type, contentId: Int, contentType: ContentType, completionHandler: @escaping (T) -> ()) {
        
        if let place = localRealm.object(ofType: type, forPrimaryKey: contentId) {
            completionHandler(place)
        } else {
            requestData(router: .typeInfo(contentId, contentType)) { [weak self] (result: APIResult<[T]>) in
                print("장소 세부 데이터 잘 받았다🫶🫶🫶🫶🫶🫶")
                
                switch result {
                case let .success(data):
                    guard let detail = data.first else { return }
                    
                    self?.addObjcet(object: detail)
                    completionHandler(detail)
                default:
                    print("장소 디테일 정보 가져오기 실패")
                }
            }
        }
    }
    
    func fetchPlaceExtra (contentId: Int, contentType: ContentType, completionHandler: @escaping (ExtraPlaceInfo) -> ()) {
        
        if let place = localRealm.object(ofType: ExtraPlaceInfo.self, forPrimaryKey: contentId) {
            completionHandler(place)
        } else {
            requestData(router: .extraInfo(contentId, contentType)) { [weak self] (result: APIResult<[ExtraPlaceElement]>) in
                print("장소 추가 데이터 잘 받았다👏👏👏👏👏👏")
                
                switch result {
                case let .success(data):
                    let extra = ExtraPlaceInfo(id: contentId, infoList: data)
                    
                    self?.addObjcet(object: extra)
                    completionHandler(extra)
                default:
                    print("장소 추가 정보 가져오기 실패")
                }
            }
        }
    }
    
    func fetchPlaceImages (contentId: Int, completionHandler: @escaping ([PlaceImage]) -> ()) {
        
        if let image = localRealm.object(ofType: PlaceImageInfo.self, forPrimaryKey: contentId) {
            completionHandler(image.images)
        } else {
            requestData(router: .detailImage(contentId)) { [weak self] (result: APIResult<[PlaceImage]>) in
                print("장소 이미지 데이터 잘 받았다👻👻👻👻👻")
                
                switch result {
                case let .success(data):
                    let image = PlaceImageInfo(id: contentId, imageList: data)
                    
                    self?.addObjcet(object: image)
                    completionHandler(data)
                default:
                    print("장소 이미지 가져오기 실패")
                }
            }
        }
    }
}

// MARK: - Helper Method
extension RealmRepository {
    func printRealmFileURL() {
        print(localRealm.configuration.fileURL!.path)
    }
    
    private func addObjcet(object: Object) {
        do {
            try localRealm.write({
                localRealm.add(object)
            })
        } catch {
            print("데이터 추가 에러")
        }
    }
    
    private func addCommonPlace(info: CommonPlaceInfo, count: inout Int) -> CommonPlaceInfo {
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
    
    private func updateDiscoverDate(place: CommonPlaceInfo) {
        do {
            try localRealm.write({
                place.discoverDate = Date()
            })
        } catch {
            print("장소 발견 실패")
        }
    }
    
    private func addPlaceIntro(place: CommonPlaceInfo, intro: Intro) {
        do {
            try localRealm.write({
                place.intro = intro
            })
        } catch {
            print("장소 소개 데이터 쓰기 실패")
        }
    }
}
