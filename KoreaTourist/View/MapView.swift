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
    
    lazy var searchButton = UIButton(type: .system).then {
        
        $0.setTitle("주변의 관광지 찾기", for: .normal)
        $0.backgroundColor = .label
        $0.setTitleColor(.systemBackground, for: .normal)
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 12
    
    }
    
    lazy var circleButton = CircleMenu(frame: .zero, normalIcon: "", selectedIcon: "", duration: 0.5, distance: 85).then {
        
        $0.setImage(UIImage(systemName: "list.bullet"), for: .normal)
        $0.setImage(UIImage(systemName: "xmark"), for: .selected)
        $0.backgroundColor = .systemBackground
        $0.startAngle = -90
        $0.endAngle = 90
        
        $0.layer.shadowOffset = .zero
        $0.layer.shadowOpacity = 0.5
        
    }
    
    
    lazy var trackControl = NMFLocationButton().then {
        
        $0.mapView = mapView
        
    }
    
    private func configureMapView() {
        
        // 서울시청 좌표
        let defaultCameraPosition = NMFCameraPosition(NMGLatLng(lat: 37.56661, lng: 126.97839), zoom: 10, tilt: 0, heading: 0)
        
        showZoomControls = false
        mapView.logoAlign = .rightTop
        mapView.maxZoomLevel = 18
        mapView.minZoomLevel = 10
        mapView.mapType = .navi
        mapView.moveCamera(NMFCameraUpdate(position: defaultCameraPosition))
        mapView.positionMode = .direction
        //                naverMapView.showLocationButton = true
        
        if traitCollection.userInterfaceStyle == .dark {
            mapView.backgroundImage = NMFDefaultBackgroundDarkImage
            mapView.backgroundColor = NMFDefaultBackgroundDarkColor
            mapView.isNightModeEnabled = true
        }
    }
    
    private func configureButton() {
        
//        addSubview(searchButton)
        
        [trackControl, circleButton].forEach { addSubview($0) }
        
//        searchButton.snp.makeConstraints { make in
//            make.leading.trailing.bottom.equalToSuperview().inset(28)
//            make.height.equalTo(60)
//        }
        trackControl.snp.makeConstraints { make in
            make.leading.equalTo(28)
            make.bottom.equalTo(-60)
//            make.bottom.equalTo(-28)
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


