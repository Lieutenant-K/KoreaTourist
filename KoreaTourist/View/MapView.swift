//
//  MapView.swift
//  KakaoMap
//
//  Created by 김윤수 on 2022/09/19.
//

import UIKit
import NMapsMap
import SnapKit

class MapView: NMFNaverMapView {
    
    let infoWindow = NMFInfoWindow()
    
    lazy var searchButton: UIButton = {
        let view = UIButton(type: .system)
        view.setTitle("주변의 관광지 찾기", for: .normal)
        view.backgroundColor = .label
        view.setTitleColor(.systemBackground, for: .normal)
        view.clipsToBounds = true
        view.layer.cornerRadius = 12
        return view
    }()
    
    lazy var trackControl: NMFLocationButton = {
        let button = NMFLocationButton()
        button.mapView = mapView
        return button
    }()
    
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
        
        addSubview(searchButton)
        addSubview(trackControl)
        
        searchButton.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview().inset(28)
            make.height.equalTo(60)
        }
        trackControl.snp.makeConstraints { make in
            make.leading.equalTo(28)
            make.bottom.equalTo(searchButton.snp.top).offset(-12)
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


