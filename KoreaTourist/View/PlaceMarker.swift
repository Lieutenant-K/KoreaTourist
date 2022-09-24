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
    static let minimunDistance: Double = 400
    
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
            captionColor = .black
            subCaptionText = ""
            iconImage = NMF_MARKER_IMAGE_YELLOW
            zIndex = 0
            return
        }
        
        subCaptionText = "\(Int(distance))m"
        
        if distance <= Self.minimunDistance {
            captionText = "발견가능"
            captionColor = .systemBlue
            zIndex = 2
            iconImage = NMF_MARKER_IMAGE_BLUE
        } else {
            captionText = "미발견"
            captionColor = .black
            iconImage = NMF_MARKER_IMAGE_GRAY
            zIndex = 1
        }
        
    }
    
    private func configureMarker() {
        
        position = NMGLatLng(lat: placeInfo.lat, lng: placeInfo.lng)
        iconImage = NMF_MARKER_IMAGE_GRAY
        isHideCollidedSymbols = true
        isHideCollidedCaptions = true
        iconPerspectiveEnabled = true
        captionPerspectiveEnabled = true
        captionMinZoom = 14
        captionRequestedWidth = 4
        subCaptionTextSize = 10
    
        updateMarkerAppearnce()
        
    }
    
}
