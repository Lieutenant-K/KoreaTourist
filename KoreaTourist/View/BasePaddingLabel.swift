//
//  BasePaddingLabel.swift
//  KakaoMap
//
//  Created by 김윤수 on 2022/09/15.
//

import UIKit

class BasePaddingLabel: UILabel {
    private var padding = UIEdgeInsets(top: 16.0, left: 16.0, bottom: 16.0, right: 16.0)

    convenience init(padding: UIEdgeInsets) {
        self.init()
        self.padding = padding
    }
    
    convenience init(value: CGFloat) {
        let inset = UIEdgeInsets(top: value, left: value, bottom: value, right: value)
        self.init(padding: inset)
    }

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: padding))
    }

    override var intrinsicContentSize: CGSize {
        var contentSize = super.intrinsicContentSize
        contentSize.height += padding.top + padding.bottom
        contentSize.width += padding.left + padding.right

        return contentSize
    }
}
