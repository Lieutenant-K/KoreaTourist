//
//  ExtraPlaceInfo.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2022/12/18.
//

import Foundation
import RealmSwift

class ExtraPlaceInfo: Object {
    @Persisted(primaryKey: true) var contentId: Int
    @Persisted var infoList: List<ExtraPlaceElement>
    
    var list: [ExtraPlaceElement] {
        get { infoList.map { $0 } }
        set {
            infoList.removeAll()
            infoList.append(objectsIn: newValue)
        }
    }
    
    convenience init(id: Int, infoList: [ExtraPlaceElement]) {
        self.init()
        contentId = id
        list = infoList
    }
}
