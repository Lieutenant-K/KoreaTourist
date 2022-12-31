//
//  APIManager.swift
//  KakaoMap
//
//  Created by 김윤수 on 2022/09/12.
//

import Foundation
import Alamofire
import XMLCoder

class APIManager {
    
    static let shared = APIManager()
    
    func requestAreaCode(completionHandler: @escaping ([AreaCode]) -> ()) {
        requestData(router: .areaCode) { data in
            if let result = try? JSONDecoder().decode(Result<AreaCode>.self, from: data) {
                let codeList = result.response.body.items.item
                
                completionHandler(codeList)
            }
        }
    }
    
    func requestNearPlace(pos: Circle, failureHandler: @escaping (FailureReason) -> (), completionHandler: @escaping (_ placeList: [CommonPlaceInfo]) -> Void ) {
        requestData(router: .location(pos)) { result in
            
            if let dataList = try? JSONDecoder().decode(Result<CommonPlaceInfo>.self, from: result) {
                
                let data = dataList.response.body.items.item
                
                completionHandler(data)
                
            } else if let error = try? XMLDecoder().decode(ServiceResponse.self, from: result) {
            
                failureHandler(.apiError(error))
                
            } else {
                failureHandler(.noData)
            }
            
        }
    }
    
    func requestPlaceIntro(contentId: Int, completionHandler: @escaping (_ data: Intro) -> Void) {
        requestData(router: .commonInfo(contentId)) { data in
            if let result = try? JSONDecoder().decode(Result<Intro>.self, from: data), let info = result.response.body.items.item.first {
                
                completionHandler(info)
            }
        }
    }
    
    func requestDetailPlaceInfo<T:Codable> (contentId: Int, contentType: ContentType, completionHandler: @escaping (_ data: T) -> Void) {
        requestData(router: .typeInfo(contentId, contentType)) { data in
            
            if let result = try? JSONDecoder().decode(Result<T>.self, from: data), let info = result.response.body.items.item.first {
                
                completionHandler(info)
            }
            
        }
        
        
    }
    
    func requestExtraPlaceInfo<T:Codable> (contentId: Int, contentType: ContentType, completionHandler: @escaping (_ data: [T]) -> Void) {
        requestData(router: .extraInfo(contentId, contentType)) { data in
            if let result = try? JSONDecoder().decode(Result<T>.self, from: data) {
                let info = result.response.body.items.item
            
                completionHandler(info)
            }
            
        }
        
        
    }
    
    func requestDetailImages (contentId: Int, completionHandler: @escaping (_ data: [PlaceImage]) -> Void) {
        requestData(router: .detailImage(contentId)) { data in
            if let result = try? JSONDecoder().decode(Result<PlaceImage>.self, from: data) {
                let info = result.response.body.items.item
                
                completionHandler(info)
            }
        }
    }
    
    func requestData(router: Router, completionHandler: @escaping (Data) -> Void ) {
        AF.request(router).responseData { response in
            switch response.result {
            case let .success(data):
                print("request 성공 😁😁😁😁")
                completionHandler(data)
            case let .failure(error):
                MapViewController.progressHUD.dismiss(animated: true)
                print(error)
            }
        }
    }
    
    private init() {}
}

protocol NetworkManager {}

extension NetworkManager {
    func requestData<T: Codable>(router: Router, completionHandler: @escaping ([T]) -> Void ) {
        AF.request(router).responseData { response in
            switch response.result {
            case let .success(data):
                print("request 성공 😁😁😁😁")
                
                if let result = try? JSONDecoder().decode(Result<T>.self, from: data) {
                    let item = result.response.body.items.item
                    
                    completionHandler(item)
                } else if let message = try? XMLDecoder().decode(ServiceResponse.self, from: data) {
                    print(message.cmmMsgHeader.errMsg)
                } else {
                    print("no Data")
                }
            case let .failure(error):
                MapViewController.progressHUD.dismiss(animated: true)
                
                print(error)
            }
        }
    }
}
