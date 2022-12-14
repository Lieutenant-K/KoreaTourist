//
//  UIColor + Extension.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2022/12/15.
//

import UIKit
extension UIColor {
    
    // R: 248, G: 100, B: 100
    static let enabledMarker = UIColor(named: "enabledMarker")!
    
    // R: 69, G: 82, B:108
    static let disabledMarker = UIColor(named: "disabledMarker")!
    
    static let discoverdMarker = UIColor(named: "discoveredMarker")!
    //UIColor(red: 117/255, green: 86/255, blue: 86/255, alpha: 1)
    //UIColor(red: 84/255, green: 183/255, blue: 161/255, alpha: 1)
    
    func colorWithBrightness(brightness: CGFloat) -> UIColor {
        var H: CGFloat = 0, S: CGFloat = 0, B: CGFloat = 0, A: CGFloat = 0
        
        if getHue(&H, saturation: &S, brightness: &B, alpha: &A) {
            B += (brightness - 1.0)
            B = max(min(B, 1.0), 0.0)
            
            return UIColor(hue: H, saturation: S, brightness: B, alpha: A)
        }
        return self
    }
    
}
