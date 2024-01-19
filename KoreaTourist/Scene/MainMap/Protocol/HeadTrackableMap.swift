//
//  HeadTrackableMap.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2023/08/19.
//

import Foundation

import NMapsMap

/// 기기의 헤딩값을 추적할 수 있는 지도 객체
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
