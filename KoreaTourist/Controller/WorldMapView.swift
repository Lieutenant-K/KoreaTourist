//
//  WorldMapView.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2022/10/11.
//

import UIKit
import NMapsMap
import Then

final class WorldMapView: NMFMapView {
    
    private func configureMapView() {
        
        setDefaultValue()
        
        setDefaultLocation()
    }
    
    
    private func setDefaultValue() {
        
        logoAlign = .leftBottom
        maxZoomLevel = 18
        minZoomLevel = 8
//        maxTilt = maxTilt
//        contentInset = contentInset
        setLayerGroup(NMF_LAYER_GROUP_BUILDING, isEnabled: false)
        symbolScale = 0.5
        mapType = .navi
        
        adjustInterfaceStyle(style: UITraitCollection.current.userInterfaceStyle)
        
    }
    
    private func setDefaultLocation() {
        
        // 서울시청 좌표
        let baseLocation = NMGLatLng(lat: 37.56661, lng: 126.97839)
        
        let defaultCameraPosition = NMFCameraPosition(baseLocation, zoom: minZoomLevel, tilt: 0, heading: 0)
        moveCamera(NMFCameraUpdate(position: defaultCameraPosition))
        
        
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        
        let style = UITraitCollection.current.userInterfaceStyle
        
        adjustInterfaceStyle(style: style)
        
    }

    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureMapView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
