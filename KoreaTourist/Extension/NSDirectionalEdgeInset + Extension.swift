//
//  NSDirectionalEdgeInset + Extension.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2022/12/15.
//

import UIKit

extension NSDirectionalEdgeInsets {
    init(value: CGFloat){
        self.init(top: value, leading: value, bottom: value, trailing: value)
    }
}
