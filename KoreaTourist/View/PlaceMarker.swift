//
//  PlaceMarker.swift
//  KakaoMap
//
//  Created by 김윤수 on 2022/09/13.
//

import UIKit
import NMapsMap

final class PlaceMarker: NMFMarker {
    
    // 디버그용
    static let minimunDistance: Double = 100000000
    
    let placeInfo: CommonPlaceInfo
    
    var distance: Double {
        didSet {
            updateMarkerAppearnce()
        }
    }
    
    init(place: CommonPlaceInfo) {
        self.placeInfo = place
        self.distance = place.dist
        super.init()
        
        configureMarker()
    }
    
    func updateMarkerAppearnce() {
        
        if placeInfo.isDiscovered {
            captionText = placeInfo.title
            captionColor = .green
            subCaptionText = ""
            iconImage = NMF_MARKER_IMAGE_GREEN
            return
        }
        
        subCaptionText = "\(Int(distance))m"
        
        if distance <= Self.minimunDistance {
            captionText = "발견 가능"
            captionColor = .systemBlue
            iconImage = NMF_MARKER_IMAGE_BLUE
        } else {
            captionText = "미발견"
            captionColor = .black
            iconImage = NMF_MARKER_IMAGE_GRAY
        }
        
    }
    
    private func configureMarker() {
        
        position = NMGLatLng(lat: placeInfo.lat, lng: placeInfo.lng)
        iconImage = NMF_MARKER_IMAGE_GRAY
        isHideCollidedSymbols = true
        captionMinZoom = 14
        captionRequestedWidth = 12
        subCaptionTextSize = 8
        
//        distance = placeInfo.dist
        updateMarkerAppearnce()
        
    }
    
}
