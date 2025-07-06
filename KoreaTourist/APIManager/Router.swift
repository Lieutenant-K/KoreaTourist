//
//  Router.swift
//  KakaoMap
//
//  Created by 김윤수 on 2022/09/13.
//

import Foundation

import Alamofire

enum Router: URLRequestConvertible {
    private var baseURL: String {
        "https://apis.data.go.kr/B551011/KorService2"
    }

    private var baseParameter: [String: Any] {
        [
            "serviceKey": APIKey.tourAPI.key,
            "MobileOS": "IOS",
            "MobileApp": "Test",
            "_type": "json",
        ]
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
            return "/locationBasedList2"
        case .areaCode:
            return "/areaCode2"
        case .commonInfo:
            return "/detailCommon2"
        case .typeInfo:
            return "/detailIntro2"
        case .extraInfo:
            return "/detailInfo2"
        case .detailImage:
            return "/detailImage2"
        }
    }

    // MARK: - Parameters

    var parameters: Parameters {
        switch self {
        case let .location(circle):
            return [
                "numOfRows": 30,
                "pageNo": 1,
                "mapX": circle.x,
                "mapY": circle.y,
                "radius": circle.radius,
                "contentTypeId": 12,
                "arrange": "E",
            ]
        case .areaCode:
            return ["numOfRows": 20, "pageNo": 1]
        case let .commonInfo(id):
            return [
                "contentId": id,
                // "overviewYN": "Y",
                // "catcodeYN": "Y",
                // "addrinfoYN": "Y",
                // "defaultYN": "Y",
                // "firstImageYN": "Y",
                // "areacodeYN": "Y",
                // "mapinfoYN": "Y",
            ]
        case let .typeInfo(id, type):
            return [
                "contentId": id,
                "contentTypeId": type.rawValue,
            ]
        case let .extraInfo(id, type):
            return ["contentId": id, "contentTypeId": type.rawValue]
        case let .detailImage(id):
            return [
                "numOfRows": 20,
                "pageNo": 1,
                "contentId": id,
                "imageYN": "Y",
                // "subImageYN": "Y",
            ]
        }
    }

    // MARK: - URL Request

    func asURLRequest() throws -> URLRequest {
        guard let url = URL(string: baseURL)?.appendingPathComponent(path) else {
            throw AFError.invalidURL(url: baseURL)
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.method = method

        var param = baseParameter.merging(parameters) { left, _ in
            left
        }

        return try URLEncoding(destination: .methodDependent, arrayEncoding: .noBrackets).encode(urlRequest, with: param)
    }
}
