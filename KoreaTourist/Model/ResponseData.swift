//
//  ResponseData.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2022/12/18.
//

import Foundation

// MARK: - Result
struct Result<T:Codable>: Codable {
    let response: Response<T>
}

// MARK: - Response
struct Response<T:Codable>: Codable {
    let header: Header
    let body: Body<T>
}

// MARK: - Header
struct Header: Codable {
    let resultCode, resultMsg: String
}


// MARK: - Body
struct Body<T:Codable>: Codable {
    let items: Items<T>
    let numOfRows, pageNo, totalCount: Int
}

// MARK: - Items
struct Items<T:Codable>: Codable {
    let item: [T]
}
