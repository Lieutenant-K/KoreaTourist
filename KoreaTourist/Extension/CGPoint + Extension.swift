//
//  CGPoint + Extension.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2022/12/15.
//

import UIKit
extension CGPoint {
    static var markerTop: CGPoint {
        return CGPoint(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height/2 - 100)
    }
    
    static var centerTop: CGPoint {
        CGPoint(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height/2 - 50)
    }
    
    static var buttonTop: CGPoint {
        CGPoint(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height*3/4 + 50)
    }
    
    static var top: CGPoint {
        return CGPoint(x: UIScreen.main.bounds.width/2, y: 120)
    }
}
