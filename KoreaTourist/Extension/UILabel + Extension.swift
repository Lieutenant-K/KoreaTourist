//
//  UILabel + Extension.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2022/12/15.
//

import UIKit

extension UILabel {
    var isValidate: Bool {
        if let text = text, !text.isEmpty {
            return true
        } else {
            return false
        }
    }
    
    func countLines() -> Int {
      guard let myText = self.text as NSString? else {
        return 0
      }
      let rect = CGSize(width: self.bounds.width, height: CGFloat.greatestFiniteMagnitude)
      let labelSize = myText.boundingRect(with: rect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: self.font as Any], context: nil)
      return Int(ceil(CGFloat(labelSize.height) / self.font.lineHeight))
    }
}
