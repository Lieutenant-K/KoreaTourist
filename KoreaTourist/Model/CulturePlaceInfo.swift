//
//  CulturePlaceInfo.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2022/12/18.
//
import Foundation
import RealmSwift

class CulturePlaceInfo: Object, DetailInformation {
    
    var detailInfoList: [DetailInfo] { [] }
    
    var contentType: ContentType {
        get { ContentType(rawValue: contentTypeId)! }
        set { contentTypeId = newValue.rawValue }
    }
    
    @Persisted(primaryKey: true) var contentId: Int
    @Persisted var contentTypeId: String
}
