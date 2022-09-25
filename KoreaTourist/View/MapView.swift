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
    
    let geoTitleLabel = UILabel().then {
        $0.text = "현재 지역"
        $0.font = .systemFont(ofSize: 26, weight: .heavy)
        $0.textColor = .secondaryLabel
        $0.backgroundColor = .clear
        $0.textAlignment = .center
        $0.numberOfLines = 1
    }
    
    let menuButton = UIButton(type: .system).then {
        $0.setImage(UIImage(systemName: "book.closed.fill"), for: .normal)
        $0.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 24, weight: .bold), forImageIn: .normal)
        $0.tintColor = .white
        $0.backgroundColor = .clear
    }
    
    let circleButton = CircleMenu(frame: .zero, normalIcon: "", selectedIcon: "", duration: 0.5, distance: 85).then {
        
        $0.setImage(UIImage(systemName: "list.bullet"), for: .normal)
        $0.setImage(UIImage(systemName: "xmark"), for: .selected)
        $0.backgroundColor = .white
        $0.startAngle = -90
        $0.endAngle = 90
        
        $0.layer.shadowOffset = .zero
        $0.layer.shadowOpacity = 0.3
        
    }
    
    
    private lazy var trackControl = NMFLocationButton().then {
        $0.mapView = mapView
        
    }
    
    private lazy var compass = NMFCompassView().then {
        $0.mapView = mapView
        $0.isUserInteractionEnabled = false
    }
    
    let circleOverlay = NMFCircleOverlay(NMGLatLng(lat: 0, lng: 0), radius: Circle.defaultRadius).then {
        $0.fillColor = .systemBlue.withAlphaComponent(0.05)
        $0.outlineWidth = 2.5
        $0.outlineColor = .white
    }
    
    let cameraButton = UIButton(type: .system).then {
        /*
        var config = UIButton.Configuration.plain()
        config.imagePlacement = .leading
        config.image = UIImage(systemName: "location.fill")
        config.imagePadding = 8
        config.cornerStyle = .large
        config.title = "탐색모드로 돌아가기"
        config.background.backgroundColor = .white
        config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        
        $0.configuration = config
         */
        $0.setImage(UIImage(systemName: "location.fill"), for: .normal)
        $0.isHidden = true
        $0.backgroundColor = .white
        $0.layer.shadowOffset = .zero
        $0.layer.shadowOpacity = 0.3
    }
    
    private func configureMapView() {
        
        showZoomControls = false
        showCompass = false
//        showScaleBar = true
        mapView.logoAlign = .rightBottom
        mapView.maxZoomLevel = 18
        mapView.minZoomLevel = 15
        mapView.maxTilt = maxTilt
        mapView.contentInset = contentInset
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
        mapView.isStopGestureEnabled = false
        
        if traitCollection.userInterfaceStyle == .dark {
            mapView.backgroundImage = NMFDefaultBackgroundDarkImage
            mapView.backgroundColor = NMFDefaultBackgroundDarkColor
            mapView.isNightModeEnabled = true
        }
        
    }
    
    private func configureButton() {
        
        [trackControl, circleButton, compass, cameraButton, geoTitleLabel, menuButton].forEach { addSubview($0) }
        
        trackControl.snp.makeConstraints { make in
            make.leading.equalTo(28)
            make.bottom.equalTo(-60)
        }
        
        compass.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide)
            make.leading.equalTo(12)
//            make.bottom.equalTo(-60)
        }
        
        geoTitleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(safeAreaLayoutGuide)
            make.leading.greaterThanOrEqualTo(20)
            make.trailing.lessThanOrEqualTo(-20)
        }
        
        menuButton.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide)
            make.trailing.equalTo(-12)
        }
        
        let buttonWidth = 50.0
        
        circleButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(-60)
            make.width.equalTo(buttonWidth)
            make.height.equalTo(circleButton.snp.width)
        }
        
        cameraButton.snp.makeConstraints { make in
            make.trailing.equalTo(-28)
            make.bottom.equalTo(-60)
            make.width.equalTo(buttonWidth)
            make.height.equalTo(circleButton.snp.width)
        }
        
        circleButton.layer.cornerRadius = buttonWidth/2
        cameraButton.layer.cornerRadius = buttonWidth/2
    }
    
    func moveCamera(_ update: NMFCameraUpdate, completionHandler: @escaping () -> ()) {
        
        panGesture.isEnabled = false
        pinchGesture.isEnabled = false
        
        mapView.moveCamera(update) { [weak self] bool in
            print("카메라 전환 완료 👍👍👍👍👍", bool)
            self?.panGesture.isEnabled = true
            self?.pinchGesture.isEnabled = true
            completionHandler()
        }
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
    
    var maxTilt: Double { 63 }
    
    var minTilt: Double { 13 }
    
    var contentInset: UIEdgeInsets {
        UIEdgeInsets(top: 0, left: 0, bottom: -UIScreen.main.bounds.height/2, right: 0)
    }
    
    var currentTilt: Double { mapView.cameraPosition.tilt }
    
    var currentZoom: Double { mapView.cameraPosition.zoom }
    
    var maxLocOverlaySize: CGFloat { 250 }
    
    var minLocOverlaySize: CGFloat { 100 }
    
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
