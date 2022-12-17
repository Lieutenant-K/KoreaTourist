//
//  Intro.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2022/12/18.
//

import Foundation
import RealmSwift

class Intro: EmbeddedObject, Codable {
    @Persisted var zipcode: Int
    @Persisted var overview: String
    @Persisted var homepage : String
    @Persisted var tel: String
    @Persisted var telName: String
    
    enum CodingKeys: String, CodingKey {
        case zipcode, overview, homepage, tel
        case telName = "telname"
    }
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        zipcode = Int(try container.decode(String.self, forKey: .zipcode)) ?? 0
        overview = (try container.decode(String.self, forKey: .overview)).htmlEscaped.refine
        homepage = (try container.decode(String.self, forKey: .homepage)).htmlEscaped
        tel = try container.decode(String.self, forKey: .tel)
        telName = try container.decode(String.self, forKey: .telName)
    }
}
