//
//  MapView.swift
//  KakaoMap
//
//  Created by 김윤수 on 2022/09/19.
//

import UIKit
import NMapsMap
import SnapKit
import CircleMenu
import Then

final class MapView: NMFNaverMapView {
    
    let infoWindow = NMFInfoWindow()
    
    let panGesture = UIPanGestureRecognizer()
    
    let pinchGesture = UIPinchGestureRecognizer()
    
    
    lazy var circleButton = CircleMenu(frame: .zero, normalIcon: "", selectedIcon: "", duration: 0.5, distance: 85).then {
        
        $0.setImage(UIImage(systemName: "list.bullet"), for: .normal)
        $0.setImage(UIImage(systemName: "xmark"), for: .selected)
        $0.backgroundColor = .white
        $0.startAngle = -90
        $0.endAngle = 90
        
        $0.layer.shadowOffset = .zero
        $0.layer.shadowOpacity = 0.3
        
    }
    
    
    lazy var trackControl = NMFLocationButton().then {
        
        $0.mapView = mapView
        
    }
    
    private func configureMapView() {
        
        showZoomControls = false
//        showScaleBar = true
        mapView.logoAlign = .rightTop
        mapView.maxZoomLevel = 18
        mapView.minZoomLevel = 15
        mapView.maxTilt = maxTilt
        mapView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: -UIScreen.main.bounds.height/2, right: 0)
        mapView.setLayerGroup(NMF_LAYER_GROUP_BUILDING, isEnabled: false)
        mapView.symbolScale = 0.5
        mapView.mapType = .navi
        mapView.positionMode = .direction
        
        // 서울시청 좌표
        let baseLocation = NMGLatLng(lat: 37.56661, lng: 126.97839)
        
        let defaultCameraPosition = NMFCameraPosition(baseLocation, zoom: mapView.maxZoomLevel, tilt: maxTilt, heading: 0)
        mapView.moveCamera(NMFCameraUpdate(position: defaultCameraPosition))
        
        mapView.locationOverlay.location = baseLocation
        locOverlaySize = CGSize(width: maxLocOverlaySize, height: maxLocOverlaySize)
        
        // MARK: Gesture Configuration
        mapView.addGestureRecognizer(panGesture)
        mapView.addGestureRecognizer(pinchGesture)
        mapView.isScrollGestureEnabled = false
        mapView.isZoomGestureEnabled = false
        mapView.isRotateGestureEnabled = false
        mapView.isTiltGestureEnabled = false
        
        if traitCollection.userInterfaceStyle == .dark {
            mapView.backgroundImage = NMFDefaultBackgroundDarkImage
            mapView.backgroundColor = NMFDefaultBackgroundDarkColor
            mapView.isNightModeEnabled = true
        }
        
    }
    
    private func configureButton() {
        
        [trackControl, circleButton].forEach { addSubview($0) }
        
        trackControl.snp.makeConstraints { make in
            make.leading.equalTo(28)
            make.bottom.equalTo(-60)

        }
        
        let buttonWidth = 50.0
        
        circleButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(-60)
            make.width.equalTo(buttonWidth)
            make.height.equalTo(circleButton.snp.width)
        }
        circleButton.layer.cornerRadius = buttonWidth/2
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureMapView()
        configureButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


extension MapView {
    
    var maxTilt: Double {
        return 63
    }
    
    var minTilt: Double {
        return 13
    }
    
    var currentTilt: Double {
        return mapView.cameraPosition.tilt
    }
    
    var currentZoom: Double {
        return mapView.cameraPosition.zoom
    }
    
    var maxLocOverlaySize: CGFloat {
        250
    }
    
    var minLocOverlaySize: CGFloat {
        100
    }
    
    var locOverlaySize: CGSize {
        
        get {
            let overlay = mapView.locationOverlay
            return CGSize(width: overlay.iconWidth, height: overlay.iconHeight)
        }
        set {
            mapView.locationOverlay.iconWidth = newValue.width
            mapView.locationOverlay.iconHeight = newValue.height
        }
    }
    
}
