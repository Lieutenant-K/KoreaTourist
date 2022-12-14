//
//  UITableViewCell + Extension.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2022/12/15.
//

import UIKit
extension UITableViewCell {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}
