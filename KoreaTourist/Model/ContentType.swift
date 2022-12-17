//
//  ContentType.swift
//  
//
//  Created by 김윤수 on 2022/12/18.
//

import Foundation

enum ContentType: String, Codable {
    case tour = "12"
    case culture = "14"
    case event = "15"
    
    var description: String {
        switch self {
        case .tour:
            return "관광지"
        case .culture:
            return "문화시설"
        case .event:
            return "행사/공연/축제"
        }
    }
    
    var detailInfoType: DetailInformation.Type {
        switch self {
        case .tour:
            return TourPlaceInfo.self
        case .culture:
            return CulturePlaceInfo.self
        case .event:
            return EventPlaceInfo.self
        }
    }
}
