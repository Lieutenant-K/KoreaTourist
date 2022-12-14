//
//  CALayer + Extension.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2022/12/15.
//

import UIKit
extension CALayer {
    enum BorderEdge: String, CaseIterable {
        case top, bottom, left, right
        
        func rect(frame: CGRect, width: CGFloat) -> CGRect {
            switch self {
            case .top:
                return CGRect(x: 0, y: 0, width: frame.width, height: width)
            case .bottom:
                return CGRect(x: 0, y: frame.height - width, width: frame.width, height: width)
            case .left:
                return CGRect.init(x: 0, y: 0, width: width, height: frame.height)
            case .right:
                return CGRect.init(x: frame.width - width, y: 0, width: width, height: frame.height)
            }
        }
    }
    
    func addBorderLine(color: UIColor, edge: [BorderEdge], width: CGFloat) {
        edge.forEach {
            let border = CALayer()
            border.frame = $0.rect(frame: self.frame, width: width)
            border.cornerRadius = 1
            border.backgroundColor = color.cgColor
            border.name = $0.rawValue
            
            self.addSublayer(border)
        }
    }
    
    func removeAllBorderLine() {
        BorderEdge.allCases.forEach { edge in
            sublayers?.forEach {
                if $0.name == edge.rawValue {
                    $0.removeFromSuperlayer()
                }
            }
        }
    }
}
