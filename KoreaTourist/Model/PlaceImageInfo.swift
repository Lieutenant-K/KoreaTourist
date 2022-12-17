//
//  PlaceImageInfo.swift
//  
//
//  Created by 김윤수 on 2022/12/18.
//

import Foundation
import RealmSwift

class PlaceImageInfo: Object {
    @Persisted(primaryKey: true) var contentId: Int
    @Persisted var imageList: List<PlaceImage>
    
    var images: [PlaceImage] {
        get { imageList.map { $0 } }
        set {
            imageList.removeAll()
            imageList.append(objectsIn: newValue)
        }
    }
    
    convenience init(id: Int, imageList: [PlaceImage]) {
        self.init()
        contentId = id
        images = imageList
    }
}
