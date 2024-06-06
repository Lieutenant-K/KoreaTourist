//
//  NetworkServiceManager.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2023/05/23.
//

import Foundation
import Combine

import Alamofire
import XMLCoder

enum NetworkError: Error {
    case apiError(ServiceResponse)
    case noData
    case alamofire(AFError)
}

final class NetworkManager {
    func request<T: Codable>(router: Router, type: T.Type) -> AnyPublisher<[T], NetworkError> {
        Future<[T], NetworkError> { completion in
            AF.request(router).validate(statusCode: 200..<300).responseData { response in
                switch response.result {
                case let .success(data):
                    if let data = try? JSONDecoder().decode(Result<T>.self, from: data) {
                        completion(.success(data.response.body.items.item))
                    } else if let message = try? XMLDecoder().decode(ServiceResponse.self, from: data) {
                        completion(.failure(.apiError(message)))
                    } else {
                        completion(.failure(.noData))
                    }
                case let .failure(error):
                    completion(.failure(.alamofire(error)))
                }
            }
        }.eraseToAnyPublisher()
    }
}
