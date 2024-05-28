//
//  PlaceMarker.swift
//  KakaoMap
//
//  Created by 김윤수 on 2022/09/13.
//

import UIKit
import Combine

import NMapsMap

final class PlaceMarker: NMFMarker {
    // 디버그용
    static let minimumDistance: Double = 500
    var cancellables = Set<AnyCancellable>()
    let markerDidTapEvent = PassthroughSubject<PlaceMarker, Never>()
    let placeInfo: CommonPlaceInfo
    var distance: Double {
        didSet {
            self.updateAppearance()
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
    
    func updateAppearance() {
        let zIndex = distance <= Self.minimumDistance ? 2 : 1
        
        self.captionText = self.placeInfo.isDiscovered ? self.placeInfo.title : self.statusText
        self.subCaptionText = self.placeInfo.isDiscovered ? "" : "\(Int(distance))m"
        self.zIndex = self.placeInfo.isDiscovered ? 0 : zIndex
        self.captionColor = self.markerColor
        self.iconTintColor = self.markerColor
        self.captionHaloColor = .systemBackground
        self.subCaptionHaloColor = .systemBackground
        self.subCaptionColor = .label
    }
}

extension PlaceMarker {
    var statusColor: UIColor {
        if self.distance <= Self.minimumDistance {
            return .enabledMarker
        } else {
            return .disabledMarker
        }
    }
    
    var markerColor: UIColor {
        if self.placeInfo.isDiscovered {
            return .discoverdMarker
        } else {
            return self.statusColor
        }
    }
    
    var statusText: String {
        if self.distance <= Self.minimumDistance {
            return "발견가능"
        } else {
            return "미발견"
        }
    }
    
    
    private func configureMarker() {
        self.position = NMGLatLng(lat: placeInfo.lat, lng: placeInfo.lng)
        self.iconImage = NMF_MARKER_IMAGE_BLACK
        self.updateAppearance()
        self.configureCaption()
        self.globalZIndex = 3
        self.isHideCollidedSymbols = true
        self.isHideCollidedCaptions = true
        self.iconPerspectiveEnabled = true
        
        self.touchHandler = { [weak self] in
            if let marker = $0 as? PlaceMarker {
                self?.markerDidTapEvent.send(marker)
            }
            return true
        }
    }
    
    private func configureCaption() {
        self.captionRequestedWidth = 4
        self.captionTextSize = 24
        self.captionOffset = 4
        self.subCaptionTextSize = 20
    }
}
