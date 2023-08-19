//
//  DynamicCameraModeMap.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2023/08/19.
//

import Foundation

import NMapsMap

/// 카메라의 시점 모드를 변경할 수 있는 지도 객체
protocol DynamicCameraModeMap: NMFMapView {
    var minTilt: Double { get }
    func changeCameraMode(to mode: MapCameraMode)
}

extension DynamicCameraModeMap {
    func cameraModeParameter(config: MapCameraMode.Configuration) -> NMFCameraUpdateParams {
        let param = NMFCameraUpdateParams()
        
        switch config.coordinate {
        case let .custom(coordinate):
            param.scroll(to: NMGLatLng(lat: coordinate.latitude, lng: coordinate.longitude))
        case .userLocation:
            param.scroll(to: self.locationOverlay.location)
        }
        
        switch config.tilt {
        case let .custom(value):
            param.tilt(to: value)
        case .max:
            param.tilt(to: self.maxTilt)
        case .min:
            param.tilt(to: self.minTilt)
        }
        
        switch config.zoom {
        case let .custom(value):
            param.zoom(to: value)
        case .max:
            param.zoom(to: self.maxZoomLevel)
        case .min:
            param.zoom(to: self.minZoomLevel)
        }
        
        return param
    }
}
