//
//  PlaceImage.swift
//  
//
//  Created by 김윤수 on 2022/12/18.
//

import Foundation
import RealmSwift

class PlaceImage: EmbeddedObject, Codable {
    @Persisted var originalImage: String
    @Persisted var imageName: String
    @Persisted var serialNumber: String
    
    enum CodingKeys: String, CodingKey {
        case originalImage = "originimgurl"
        case imageName = "imgname"
        case serialNumber = "serialnum"
    }
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        originalImage = try container.decode(String.self, forKey: .originalImage)
        imageName = try container.decode(String.self, forKey: .imageName)
        serialNumber = try container.decode(String.self, forKey: .serialNumber)
    }
}
