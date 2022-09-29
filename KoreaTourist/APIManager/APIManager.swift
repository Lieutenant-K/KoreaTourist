//
//  APIManager.swift
//  KakaoMap
//
//  Created by 김윤수 on 2022/09/12.
//

import Foundation
import Alamofire
import SwiftyJSON

class APIManager {
    
    static let shared = APIManager()
    
    func requestNearPlace(pos: Circle, failureHandler: @escaping () -> (), completionHandler: @escaping (_ placeList: [CommonPlaceInfo]) -> Void ) {
    
        let requestURL = BaseURL.service(.location(pos)).url
        
        requestData(url: requestURL) { json in
//            print("주변의 찾은 장소가 없어요 ㅜㅜ")
            /*
            if let sample = dummy.data(using: .utf8), let sampleData = try? JSONDecoder().decode([CommonPlaceInfo].self, from: sample) {
                
                completionHandler(sampleData)
                
            }*/
            
            
            if let dataList = try? JSONDecoder().decode(Result<CommonPlaceInfo>.self, from: json) {
                
                let data = dataList.response.body.items.item
                
                completionHandler(data)
                
            } else {
                MapViewController.progressHUD.dismiss(animated: true)
                failureHandler()
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
//                print(String(data: data, encoding: .utf8))
                print("request 성공 😁😁😁😁")
//                let json = JSON(data)
//                print(json)
                completionHandler(data)
                
            case .failure(let error):
                MapViewController.progressHUD.dismiss(animated: true)
                print(error)
            }
        }
        
    }
    
    private init() {}
    
    
}
