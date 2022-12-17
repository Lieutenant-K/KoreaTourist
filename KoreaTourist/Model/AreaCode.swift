//
//  AreaCode.swift
//  
//
//  Created by 김윤수 on 2022/12/18.
//

import Foundation
import RealmSwift

class AreaCode: Object, Codable {
    @Persisted(primaryKey: true) var id: Int
    @Persisted var name: String
    
    enum CodingKeys: String, CodingKey {
        case id = "code"
        case name
    }
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = Int(try container.decode(String.self, forKey: .id)) ?? -1
        name = try container.decode(String.self, forKey: .name)
    }
}
