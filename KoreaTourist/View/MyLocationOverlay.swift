//
//  MyLocationOverlay.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2023/05/20.
//

import Foundation

import NMapsMap

final class MyLocationOverlay: NMFLocationOverlay {
    
    override init() {
        super.init()
        self.hidden = false
        self.circleColor = .systemBlue.withAlphaComponent(0.1)
        self.circleRadius = 50
        self.icon = NMFOverlayImage(image: .location)
        self.location = NMGLatLng(lat: 37.56661, lng: 126.97839)
    }
}
