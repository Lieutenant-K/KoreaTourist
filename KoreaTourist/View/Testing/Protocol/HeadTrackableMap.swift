//
//  HeadTrackableMap.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2023/08/19.
//

import Foundation

import NMapsMap

protocol HeadTrackableMap: NMFMapView {}

extension HeadTrackableMap {
    func changeHead(to: Double) {
        let update = NMFCameraUpdate(heading: to)
        update.reason = Int32(NMFMapChangedByLocation)
        
        self.moveCamera(update)
        self.locationOverlay.heading = to
    }
    
    func switchHeadTracking(isOn: Bool) {
        let image: UIImage = isOn ? .navigation : .location
        self.locationOverlay.icon = NMFOverlayImage(image: image)
    }
}
