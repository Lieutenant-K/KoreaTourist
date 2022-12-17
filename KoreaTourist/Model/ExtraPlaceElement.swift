//
//  ExtraPlaceElement.swift
//  
//
//  Created by 김윤수 on 2022/12/18.
//

import Foundation
import RealmSwift

class ExtraPlaceElement: EmbeddedObject, Codable {
    @Persisted var infoText: String
    @Persisted var infoTitle: String
    @Persisted var index: Int
    @Persisted var infoType: Int
    
    var isValidate: Bool {
        return !infoTitle.isEmpty && !infoText.isEmpty
    }
    
    enum CodingKeys: String, CodingKey {
        case index = "serialnum"
        case infoTitle = "infoname"
        case infoText = "infotext"
        case infoType = "fldgubun"
    }
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        index = Int(try container.decode(String.self, forKey: .index)) ?? -1
        infoType = Int(try container.decode(String.self, forKey: .infoType)) ?? 0
        infoText = try container.decode(String.self, forKey: .infoText).htmlEscaped
        infoTitle = try container.decode(String.self, forKey: .infoTitle).htmlEscaped
    }
}
