//
//  CommonPlaceInfo.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2022/12/18.
//

import RealmSwift
import Foundation
import NMapsMap

class CommonPlaceInfo: Information {
    @Persisted var addr1: String
    @Persisted var addr2: String
    @Persisted var cat1: String
    @Persisted var cat2: String
    @Persisted var cat3: String
    @Persisted var dist: Double
    @Persisted var title: String
    @Persisted var areaCode: Int
    @Persisted var subAreaCode: Int
    @Persisted(primaryKey: true) var contentId: Int
    @Persisted var contentTypeId: String
    @Persisted var image: String
    @Persisted var thumbnail: String
    @Persisted var lat: Double
    @Persisted var lng: Double
    @Persisted var discoverDate: Date?
    @Persisted var intro: Intro?
    
    enum CodingKeys: String, CodingKey {
        case addr1, addr2, cat1, cat2, cat3, dist, title
        case areaCode = "areacode"
        case subAreaCode = "sigungucode"
        case contentId = "contentid"
        case contentTypeId = "contenttypeid"
        case image = "firstimage"
        case thumbnail = "firstimage2"
        case lat = "mapy"
        case lng = "mapx"
    }
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        addr1 = try container.decode(String.self, forKey: .addr1)
        addr2 = try container.decode(String.self, forKey: .addr2)
        cat1 = try container.decode(String.self, forKey: .cat1)
        cat2 = try container.decode(String.self, forKey: .cat2)
        cat3 = try container.decode(String.self, forKey: .cat3)
        dist = Double(try container.decode(String.self, forKey: .dist)) ?? 0
        title = try container.decode(String.self, forKey: .title)
        areaCode = Int(try container.decode(String.self, forKey: .areaCode)) ?? 0
        subAreaCode = Int(try container.decode(String.self, forKey: .subAreaCode)) ?? 0
        contentId = Int(try container.decode(String.self, forKey: .contentId)) ?? 0
        contentTypeId = try container.decode(String.self, forKey: .contentTypeId)
        image = try container.decode(String.self, forKey: .image)
        thumbnail = try container.decode(String.self, forKey: .thumbnail)
        lat = Double(try container.decode(String.self, forKey: .lat)) ?? 0
        lng = Double(try container.decode(String.self, forKey: .lng)) ?? 0
    }
}

extension CommonPlaceInfo {
    var contentType: ContentType {
        get { ContentType(rawValue: contentTypeId)! }
        set { contentTypeId = newValue.rawValue }
    }
    
    var isDiscovered: Bool {
        return discoverDate == nil ? false : true
    }
    
    var fullAddress: String {
        var address = [addr1, addr2]
        if let zip = intro?.zipcode {
            address.append("(\(zip))")
        }
        return address.joined(separator: " ")
    }
    
    var isImageIncluded: Bool {
        return !image.isEmpty || !thumbnail.isEmpty
    }
    
    var position: NMGLatLng {
        NMGLatLng(lat: lat, lng: lng)
    }
}
