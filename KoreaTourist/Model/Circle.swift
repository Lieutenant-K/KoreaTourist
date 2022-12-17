//
//  Circle.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2022/12/18.
//

import Foundation

struct Circle {
    static let defaultRadius: Double = 500
    static let visitKorea = Circle(x: 126.981611, y: 37.568477, radius: defaultRadius)
    static let home = Circle(x: 126.924378, y: 37.503886, radius: defaultRadius)
    
    let x: Double
    let y: Double
    let radius: Double
}
