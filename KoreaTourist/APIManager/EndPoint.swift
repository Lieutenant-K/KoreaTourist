//
//  EndPoint.swift
//  KakaoMap
//
//  Created by 김윤수 on 2022/09/13.
//

import Foundation

enum BaseURL {
    
    static let baseURL = "https://apis.data.go.kr/B551011/KorService/"
    
    case service(ServiceType)
    
    var url: String {
        switch self {
        case .service(let type):
            return (Self.baseURL + type.path + type.query.string)
        }
    }
}

enum ServiceType {
    
    case location(Circle)
    case areaCode
    case commonInfo(Int)
    case typeInfo(Int, ContentType)
    case extraInfo(Int, ContentType)
    case detailImage(Int)
    
    var path: String {
        switch self {
        case .location:
            return "locationBasedList?"
        case .areaCode:
            return "areaCode?"
        case .commonInfo:
            return "detailCommon?"
        case .typeInfo:
            return "detailIntro?"
        case .extraInfo:
            return "detailInfo?"
        case .detailImage:
            return "detailImage?"
        }
    }
    
    fileprivate var query: QueryString {
        return QueryString.query(self)
    }
}

fileprivate enum QueryString {
    
    static let baseParameter = "serviceKey=\(APIKey.tourAPIKey)&MobileOS=IOS&MobileApp=Test&_type=json&"
    
    case query(ServiceType)
    
    private var parameter: String {
        switch self {
        case .query(let serviceType):
            switch serviceType {
            case .location(let position):
                return "numOfRows=30&pageNo=1&mapX=\(position.x)&mapY=\(position.y)&radius=\(position.radius)&listYN=Y&contentTypeId=12&arrange=E"
            case .areaCode:
                return "numOfRows=20&pageNo=1"
            case .commonInfo(let id):
                return "contentId=\(id)&overviewYN=Y&catcodeYN=Y&addrinfoYN=Y&defaultYN=Y&firstImageYN=Y&areacodeYN=Y&mapinfoYN=Y"
            case .typeInfo(let id, let type):
                return "contentId=\(id)&contentTypeId=\(type.rawValue)"
            case .extraInfo(let id, let type):
                return "contentId=\(id)&contentTypeId=\(type.rawValue)"
            case .detailImage(let id):
                return "numOfRows=50&pageNo=1&contentId=\(id)&imageYN=Y&subImageYN=Y"
            }
        }
    }
    
    var string: String {
        return Self.baseParameter + self.parameter
    }
    
}
