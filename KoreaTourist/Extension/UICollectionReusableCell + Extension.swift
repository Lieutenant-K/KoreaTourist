//
//  UIReusableCell.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2022/12/15.
//

import UIKit
extension UICollectionReusableView {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}
