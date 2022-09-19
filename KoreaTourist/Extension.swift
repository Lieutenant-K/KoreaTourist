//
//  Extension.swift
//  KakaoMap
//
//  Created by 김윤수 on 2022/09/15.
//

import UIKit
import Kingfisher
import NMapsMap

extension UIImage {
    
    static let pawprint = UIImage(systemName: "pawprint.fill")!
    
}

extension UIViewController {
    
    func showAlert(title: String, message:String = "", actions: [UIAlertAction] = [UIAlertAction(title: "확인", style: .cancel)] ) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        actions.forEach { alert.addAction($0) }
        
        present(alert, animated: true)
        
    }
    
}

extension UILabel {
    
    var isValidate: Bool {
        if let text = text, !text.isEmpty {
            return true
        } else {
            return false
        }
    }
    
}

extension UIImageView {
    
    convenience init(systemName: String) {
        let image = UIImage(systemName: systemName)
        self.init(image: image)
    }
}

extension UITableViewCell {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

extension UICollectionViewCell {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

extension String {
    
    var refine: String {
//        var string = self
//        let target = ["<br />", "<br>", "<b>", "<>"]
//        target.forEach { string = string.replacingOccurrences(of: $0, with: "") }
        return self.replacingOccurrences(of: ".", with: ".\n\n").trimmingCharacters(in: .whitespacesAndNewlines)
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
            let attributed = try NSAttributedString(data: encodedData,
                                                    options: options,
                                                    documentAttributes: nil)
            return attributed.string
        } catch {
            return self
        }
    }
}

extension NMFMapView {
    
    func adjustInterfaceStyle(style: UIUserInterfaceStyle) {
        
        if style == .dark {
            self.backgroundImage = NMFDefaultBackgroundDarkImage
            self.backgroundColor = NMFDefaultBackgroundDarkColor
            self.isNightModeEnabled = true
        } else {
            self.backgroundImage = NMFDefaultBackgroundLightImage
            self.backgroundColor = NMFDefaultBackgroundLightColor
            self.isNightModeEnabled = false
        }
        
    }
    
    
    
}
