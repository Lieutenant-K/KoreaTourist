//
//  APIResult.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2023/01/02.
//

import Foundation

enum APIResult<T: Codable> {
    case success(T)
    case apiError(ServiceResponse)
    case undefinedData
    case failure(Error)
}
