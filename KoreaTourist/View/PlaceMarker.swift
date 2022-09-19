//
//  PlaceMarker.swift
//  KakaoMap
//
//  Created by 김윤수 on 2022/09/13.
//

import UIKit
import NMapsMap

class PlaceMarker: NMFMarker {
    
    let placeInfo: CommonPlaceInfo
    
    var distance: Double = 0 {
        didSet {
//            print(#function)
            subCaptionText = "\(Int(distance))m"
            if distance <= 100 {
                captionText = "발견 가능"
                captionColor = .systemBlue
                iconImage = NMF_MARKER_IMAGE_BLUE
            } else {
                captionText = "미발견"
                iconImage = NMF_MARKER_IMAGE_GRAY
                captionColor = .black
            }
        }
    }
    
    init(place: CommonPlaceInfo, touchHandler: NMFOverlayTouchHandler? = nil) {
        self.placeInfo = place
        super.init()
        self.touchHandler = touchHandler
        configureMarker()
    }
    
    func configureMarker() {
        
        position = NMGLatLng(lat: placeInfo.lat, lng: placeInfo.lng)
        iconImage = NMF_MARKER_IMAGE_GRAY
        isHideCollidedSymbols = true
        captionMinZoom = 14
        subCaptionTextSize = 8
        
        distance = placeInfo.dist
        
        //        captionText = "미발견"
//        subCaptionText = "\(Int(placeInfo.dist))m"
        
    }
    
}
