//
//  NMFMapView + Extension.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2022/12/15.
//

import UIKit
import NMapsMap

extension NMFMapView {
//    func moveCameraGestureDisabled(_ cameraUpdate: NMFCameraUpdate, completion: ((Bool) -> Void)? = nil) {
//        self.gestureRecognizers?.forEach { $0.isEnabled = false }
//        self.moveCamera(cameraUpdate) {
//            completion?($0)
//            self.gestureRecognizers?.forEach { $0.isEnabled = true }
//        }
//    }
    
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

extension NMGLatLng {
    var coordinate: Coordinate {
        Coordinate(latitude: self.lat, longitude: self.lng)
    }
}
