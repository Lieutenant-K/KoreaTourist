//
//  EndPoint.swift
//  KakaoMap
//
//  Created by 김윤수 on 2022/09/13.
//

import Foundation
import Alamofire

enum Router: URLRequestConvertible {
    private static var baseURL: URL {
        URL(string: "https://apis.data.go.kr/B551011/KorService")!
    }
    
    private static var baseParameter:[String: Any] {
        ["serviceKey":APIKey.tourAPIKey,
         "MobileOS":"IOS",
         "MobileApp":"Test",
         "_type":"json"]
    }
    
    // MARK: - Cases
    case location(Circle)
    case areaCode
    case commonInfo(Int)
    case typeInfo(Int, ContentType)
    case extraInfo(Int, ContentType)
    case detailImage(Int)
    
    // MARK: - Methods
    var method: HTTPMethod {
        return .get
    }
    
    // MARK: - Paths
    var path: String {
        switch self {
        case .location:
            return "/locationBasedList"
        case .areaCode:
            return "/areaCode"
        case .commonInfo:
            return "/detailCommon"
        case .typeInfo:
            return "/detailIntro"
        case .extraInfo:
            return "/detailInfo"
        case .detailImage:
            return "/detailImage"
        }
    }
    
    // MARK: - Parameters
    var parameters: Parameters? {
        switch self {
        case .location(let circle):
            return ["numOfRows":30,
                    "pageNo":1,
                    "mapX":circle.x,
                    "mapY":circle.y,
                    "radius":circle.radius,
                    "listYN":"Y",
                    "contentTypeId":12,
                    "arrange":"E"]
        case .areaCode:
            return ["numOfRows":20, "pageNo": 1]
        case .commonInfo(let id):
            return ["contentId": id,
                    "overviewYN":"Y",
                    "catcodeYN": "Y",
                    "addrinfoYN":"Y",
                    "defaultYN":"Y",
                    "firstImageYN":"Y",
                    "areacodeYN":"Y",
                    "mapinfoYN":"Y"]
        case .typeInfo(let id, let type):
            return ["contentId":id, "contentTypeId":type.rawValue]
        case .extraInfo(let id, let type):
            return ["contentId":id, "contentTypeId":type.rawValue]
        case .detailImage(let id):
            return ["numOfRows":20,
                    "pageNo":1,
                    "contentId":id,
                    "imageYN":"Y",
                    "subImageYN":"Y"]
        }
    }
    
    
    // MARK: - URL Request
    func asURLRequest() throws -> URLRequest {
        let url = Self.baseURL.appendingPathComponent(self.path)
        var urlRequest = URLRequest(url: url)
    
        urlRequest.method = method
        
        if let parameters = parameters {
            let param = Self.baseParameter.merging(parameters) { left, _ in
                return left }
            
            return try URLEncoding(destination: .methodDependent, arrayEncoding: .noBrackets).encode(urlRequest, with: param)
        }

        return urlRequest
    }
}

