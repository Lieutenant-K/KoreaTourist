//
//  APIManager.swift
//  KakaoMap
//
//  Created by 김윤수 on 2022/09/12.
//

import Foundation
import Alamofire
import SwiftyJSON
import XMLCoder


class APIManager {
    
    static let shared = APIManager()
    
    func requestAreaCode(completionHandler: @escaping ([AreaCode]) -> ()) {
        
        let requestURL = BaseURL.service(.areaCode).url
        
        requestData(url: requestURL) { data in
            
            if let result = try? JSONDecoder().decode(Result<AreaCode>.self, from: data) {
                
                let codeList = result.response.body.items.item
                
                completionHandler(codeList)
                
            }
            
        }
        
    }
    
    func requestNearPlace(pos: Circle, failureHandler: @escaping (FailureReason) -> (), completionHandler: @escaping (_ placeList: [CommonPlaceInfo]) -> Void ) {
    
        let requestURL = BaseURL.service(.location(pos)).url
        
        requestData(url: requestURL) { result in
            
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
        print(#function)
        let requestURL = BaseURL.service(.commonInfo(contentId)).url
        
        requestData(url: requestURL) { data in
            
            if let result = try? JSONDecoder().decode(Result<Intro>.self, from: data), let info = result.response.body.items.item.first {
                
                completionHandler(info)
                
            }
            
        }
        
        
    }
    
    func requestDetailPlaceInfo<T:Codable> (contentId: Int, contentType: ContentType, completionHandler: @escaping (_ data: T) -> Void) {
        
        let requestURL = BaseURL.service(.typeInfo(contentId, contentType)).url
        
        requestData(url: requestURL) { data in
            
            if let result = try? JSONDecoder().decode(Result<T>.self, from: data), let info = result.response.body.items.item.first {
                
//                print(info)
                completionHandler(info)
                
            }
            
        }
        
        
    }
    
    func requestExtraPlaceInfo<T:Codable> (contentId: Int, contentType: ContentType, completionHandler: @escaping (_ data: [T]) -> Void) {
        
        let requestURL = BaseURL.service(.extraInfo(contentId, contentType)).url
        
        requestData(url: requestURL) { data in
            
            if let result = try? JSONDecoder().decode(Result<T>.self, from: data) {
                
                let info = result.response.body.items.item
                
//                print(info)
                completionHandler(info)
                
            }
            
        }
        
        
    }
    
    func requestDetailImages (contentId: Int, completionHandler: @escaping (_ data: [PlaceImage]) -> Void) {
        
        let requestURL = BaseURL.service(.detailImage(contentId)).url
        
        requestData(url: requestURL) { data in
            
            if let result = try? JSONDecoder().decode(Result<PlaceImage>.self, from: data) {
                
                let info = result.response.body.items.item
                
//                print(info)
                completionHandler(info)
                
            }
            
        }
        
        
    }
    
    func requestData(url: String, completionHandler: @escaping (Data) -> Void ) {
        
        AF.request(url).validate(statusCode: 200...500).responseData { response in
            switch response.result {
            case .success(let data):

                print("request 성공 😁😁😁😁")

                if let data = try? XMLDecoder().decode(ServiceResponse.self, from: data) {
                    // 에러 메시지 처리
                }
                completionHandler(data)
                
            case .failure(let error):
                MapViewController.progressHUD.dismiss(animated: true)
                print(error)
            }
        }
        
    }
    
    private init() {}
    
    
}
