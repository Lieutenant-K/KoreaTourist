//
//  APIManager.swift
//  KakaoMap
//
//  Created by 김윤수 on 2022/09/12.
//

import Foundation
import Alamofire
import XMLCoder

protocol APIManager {}

extension APIManager {
    func requestData<T: Codable>(router: Router, completionHandler: @escaping (APIResult<[T]>) -> Void ) {
        AF.request(router).responseData { response in
            switch response.result {
            case let .success(data):
                print("request 성공 😁😁😁😁")
                
                if let result = try? JSONDecoder().decode(Result<T>.self, from: data) {
                    let item = result.response.body.items.item
                    
                    completionHandler(.success(item))
                } else if let message = try? XMLDecoder().decode(ServiceResponse.self, from: data) {
                    completionHandler(.apiError(message))
                } else {
                    completionHandler(.undefinedData)
                }
            case let .failure(error):
                completionHandler(.failure(error))
            }
        }
    }
}
