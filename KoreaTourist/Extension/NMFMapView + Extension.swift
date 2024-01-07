//
//  NMFMapView + Extension.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2022/12/15.
//

import UIKit
import NMapsMap

extension NMFMapView {
    func adjustInterfaceStyle(style: UIUserInterfaceStyle) {
        if style == .dark {
            self.backgroundImage = NMFMapView.defaultBackgroundDarkImage
            self.backgroundColor = NMFDefaultBackgroundDarkColor
            self.isNightModeEnabled = true
        } else {
            self.backgroundImage = NMFMapView.defaultBackgroundLightImage
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
