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
    static let minimumDistance: Double = 500
    let placeInfo: CommonPlaceInfo
    var distance: Double {
        didSet {
            self.updateMarkerAppearnce()
        }
    }
    var isDiscovered: Bool {
        self.placeInfo.isDiscovered
    }
    
    init(place: CommonPlaceInfo) {
        self.placeInfo = place
        self.distance = place.dist
        super.init()
        self.configureMarker()
    }
    
    func updateMarkerAppearnce() {
        let statusColor: UIColor = distance <= Self.minimumDistance ? .enabledMarker : .disabledMarker
        let markerColor: UIColor = placeInfo.isDiscovered ? .discoverdMarker : statusColor
        let statusText = distance <= Self.minimumDistance ? "발견가능" : "미발견"
        let zIndex = distance <= Self.minimumDistance ? 2 : 1
        
        self.captionText = placeInfo.isDiscovered ? placeInfo.title : statusText
        self.subCaptionText = placeInfo.isDiscovered ? "" : "\(Int(distance))m"
        self.zIndex = placeInfo.isDiscovered ? 0 : zIndex
        self.captionColor = markerColor
        self.iconTintColor = markerColor
        self.captionHaloColor = .systemBackground
        self.subCaptionHaloColor = .systemBackground
        self.subCaptionColor = .label
    }
}

extension PlaceMarker {
    private func configureMarker() {
        self.position = NMGLatLng(lat: placeInfo.lat, lng: placeInfo.lng)
        self.iconImage = NMF_MARKER_IMAGE_BLACK
        self.updateMarkerAppearnce()
        self.globalZIndex = 3
        self.isHideCollidedSymbols = true
        self.isHideCollidedCaptions = true
        self.iconPerspectiveEnabled = true
        self.captionRequestedWidth = 4
        self.captionTextSize = 30
        self.captionOffset = 4
        self.subCaptionTextSize = 24
        
        /*
        captionPerspectiveEnabled = true
        captionMinZoom = 14
        width = 50
        height = 65
         */
    }
}
