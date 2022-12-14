//
//  UIImageView + Extension.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2022/12/15.
//

import UIKit

extension UIImageView {
    convenience init(systemName: String) {
        let image = UIImage(systemName: systemName)
        self.init(image: image)
    }
}
