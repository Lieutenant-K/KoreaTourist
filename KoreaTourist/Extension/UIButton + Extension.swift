//
//  UIButton + Extension.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2022/12/15.
//

import UIKit
extension UIButton {
    func setBorderLine() {
        layer.removeAllBorderLine()
        switch state {
        case .selected:
            layer.addBorderLine(color: .separator, edge: [.right, .left], width: 1)
            layer.addBorderLine(color: .label, edge: [.top], width: 3)
        default:
            layer.addBorderLine(color: .separator, edge: [.bottom], width: 1.5)
        }
    }
}
