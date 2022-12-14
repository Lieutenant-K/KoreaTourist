//
//  String + Extension.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2022/12/15.
//

import Foundation
extension String {
    var refine: String {
        return self.replacingOccurrences(of: "다.", with: "다.\n\n").trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var htmlEscaped: String {
        guard let encodedData = self.data(using: .utf8) else {
            return self
        }
        
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        
        do {
            let attributed = try NSAttributedString(
                data: encodedData,
                options: options,
                documentAttributes: nil)
            return attributed.string
        } catch {
            return self
        }
    }
}
