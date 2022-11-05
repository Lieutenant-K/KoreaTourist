//
//  Extension.swift
//  KakaoMap
//
//  Created by 김윤수 on 2022/09/15.
//

import UIKit
import Kingfisher
import NMapsMap
import CoreLocation

extension UIImage {
    
    func imageWithColor(color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        color.setFill()

        let context = UIGraphicsGetCurrentContext()
        context?.translateBy(x: 0, y: self.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        context?.setBlendMode(CGBlendMode.normal)

        let rect = CGRect(origin: .zero, size: CGSize(width: self.size.width, height: self.size.height))
        context?.clip(to: rect, mask: self.cgImage!)
        context?.fill(rect)

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
    
    static let navigation: UIImage = UIImage(named: "navigation")!
    
    static let location:UIImage = UIImage(named: "location")!
    
    static let binoculars: UIImage = UIImage(named: "binoculars")!
    
    static let map: UIImage = UIImage(named: "map")!
     
    static let backpack: UIImage = UIImage(named: "backpack")!
    
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
    
    func countLines() -> Int {
      guard let myText = self.text as NSString? else {
        return 0
      }
      // Call self.layoutIfNeeded() if your view uses auto layout
  //      self.layoutIfNeeded()
      let rect = CGSize(width: self.bounds.width, height: CGFloat.greatestFiniteMagnitude)
      let labelSize = myText.boundingRect(with: rect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: self.font as Any], context: nil)
      return Int(ceil(CGFloat(labelSize.height) / self.font.lineHeight))
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

extension UICollectionReusableView {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

extension String {
    
    var refine: String {
//        var string = self
//        let target = ["<br />", "<br>", "<b>", "<>"]
//        target.forEach { string = string.replacingOccurrences(of: $0, with: "") }
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

extension UIColor {
    
    static let enabledMarker = UIColor(named: "enabledMarker")!
    //UIColor(red: 248/255, green: 100/255, blue: 100/255, alpha: 1)
    
    static let disabledMarker = UIColor(named: "disabledMarker")!
    //UIColor(red: 69/255, green: 82/255, blue: 108/255, alpha: 1)
    
    static let discoverdMarker = UIColor(named: "discoveredMarker")!
    //UIColor(red: 117/255, green: 86/255, blue: 86/255, alpha: 1)
    //UIColor(red: 84/255, green: 183/255, blue: 161/255, alpha: 1)
    
}

extension CGPoint {
    
    static var markerTop: CGPoint {
        return CGPoint(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height/2 - 100)
    }
    
    static var centerTop: CGPoint {
        CGPoint(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height/2 - 50)
    }
    
    static var buttonTop: CGPoint {
        CGPoint(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height*3/4 + 50)
    }
    
    static var top: CGPoint {
        return CGPoint(x: UIScreen.main.bounds.width/2, y: 120)
    }
    
}

extension UIAlertAction {
    
    static let goSettingAction = UIAlertAction(title: "설정으로 이동", style: .default) { _ in
            if let settingURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingURL)
            }
        }
    
    
}

extension CLLocationManager {
    
    func changeHeadingOrientation(with device: UIDeviceOrientation) {
        
        switch device {
        case .unknown:
            self.headingOrientation = .unknown
        case .portrait:
            self.headingOrientation = .portrait
        case .portraitUpsideDown:
            self.headingOrientation = .portraitUpsideDown
        case .landscapeLeft:
            self.headingOrientation = .landscapeLeft
        case .landscapeRight:
            self.headingOrientation = .landscapeRight
        case .faceUp:
            self.headingOrientation = .faceUp
        case .faceDown:
            self.headingOrientation = .faceDown
        default:
            break
        }
        
        
        
    }
    
}

extension NSDirectionalEdgeInsets {
    
    init(value: CGFloat){
        self.init(top: value, leading: value, bottom: value, trailing: value)
    }
    
}
