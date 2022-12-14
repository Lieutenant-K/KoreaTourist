//
//  CLLocationManager + Extension.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2022/12/15.
//

import UIKit
import CoreLocation

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
