//
//  XMLDecoding.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2022/12/18.
//

import Foundation

struct XMLHeader: Codable {
    let errMsg: String
    let returnAuthMsg: String
    let returnReasonCode: String
}

struct ServiceResponse: Codable {
    let cmmMsgHeader: XMLHeader
}

enum FailureReason {
    case apiError(ServiceResponse)
    case noData
    case networkError(Error)
}
