//
//  Coordinate.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2023/05/23.
//

import Foundation

struct Coordinate: Equatable {
    static var seoul: Coordinate {
        return Coordinate(latitude: 37.56661, longitude: 126.97839)
    }
    
    let latitude: Double
    let longitude: Double
}
