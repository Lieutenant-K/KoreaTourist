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
    static let minimumDistance: Double = 400
    
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
        
        let color: UIColor = placeInfo.isDiscovered ? .discoverdMarker : (distance <= Self.minimumDistance ? .enabledMarker : .disabledMarker)
        
        captionText = placeInfo.isDiscovered ? placeInfo.title : (distance <= Self.minimumDistance ? "발견가능" : "미발견")
        
        subCaptionText = placeInfo.isDiscovered ? "" : "\(Int(distance))m"
        
        zIndex = placeInfo.isDiscovered ? 0 : (distance <= Self.minimumDistance ? 2 : 1)
        
        captionColor = color
        iconTintColor = color
        
        
    }
    
    private func configureMarker() {
        
        position = NMGLatLng(lat: placeInfo.lat, lng: placeInfo.lng)
        iconImage = NMF_MARKER_IMAGE_BLACK
        isHideCollidedSymbols = true
        isHideCollidedCaptions = true
        iconPerspectiveEnabled = true
//        captionPerspectiveEnabled = true
        captionTextSize = 30
        captionOffset = 4
        subCaptionTextSize = 24
//        captionMinZoom = 14
        captionRequestedWidth = 4
        captionHaloColor = .systemBackground
        subCaptionColor = .label
//        width = 50
//        height = 65
        
        updateMarkerAppearnce()
        
    }
    
}
