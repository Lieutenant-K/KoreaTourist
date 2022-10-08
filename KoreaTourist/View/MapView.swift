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
    
    // MARK: - Properties
    
    let infoWindow = NMFInfoWindow()
    
    let geoTitleLabel = UILabel().then {
        $0.text = "현재 지역"
        $0.font = .systemFont(ofSize: 26, weight: .heavy)
        $0.textColor = .secondaryLabel
        $0.backgroundColor = .clear
        $0.textAlignment = .center
        $0.numberOfLines = 1
    }
    
    /*
     let menuButton = UIButton(type: .system).then {
     $0.setImage(UIImage(systemName: "gearshape.circle.fill"), for: .normal)
     $0.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 32, weight: .regular), forImageIn: .normal)
     $0.tintColor = .secondaryLabel
     $0.backgroundColor = .clear
     $0.isHidden = true
     }
     */
    
    let circleButton = CircleMenu(frame: .zero, normalIcon: "", selectedIcon: "", duration: 0.5, distance: 85).then {
        
        let image = UIImage(systemName: "list.bullet")?.applyingSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 25, weight: .semibold))
        
        let selectImage = UIImage(systemName: "xmark")?.applyingSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 25, weight: .medium))
        
        $0.setImage(image, for: .normal)
        $0.setImage(selectImage, for: .selected)
        $0.backgroundColor = .white
        $0.startAngle = -90
        $0.endAngle = 90
        
        $0.layer.shadowOffset = .zero
        $0.layer.shadowOpacity = 0.3
        
    }
    
    let trackButton = HeadTrackButton(type: .custom)
    
    
    lazy var compass = NMFCompassView().then {
        
        let tap = UITapGestureRecognizer()
        tap.addTarget(self, action: #selector(compassHanlder(_:)))
        
        $0.mapView = mapView
        $0.gestureRecognizers = [tap]
        
    }
    
    let circleOverlay = NMFCircleOverlay(NMGLatLng(lat: 0, lng: 0), radius: Circle.defaultRadius).then {
        //        $0.fillColor = .systemBlue.withAlphaComponent(0.05)
        $0.fillColor = .clear
        $0.outlineWidth = 2.5
        $0.outlineColor = .secondaryLabel
    }
    
    let cameraButton = UIButton(type: .system).then {
        
        $0.setImage(UIImage(systemName: "location.fill"), for: .normal)
        $0.isHidden = true
        $0.backgroundColor = .white
        $0.layer.shadowOffset = .zero
        $0.layer.shadowOpacity = 0.3
    }
    
    // MARK: - Method
    
    
    
    // MARK: - Configure Method
    
    private func configureMapView() {
        
        disableDefaultControl()
        
        setDefaultValue()
        
        setDefaultLocation()
        
        setLocationOverlay()
        
        setMapGesture()
        
    }
    
    private func disableDefaultControl() {
        
        showZoomControls = false
        showCompass = false
        showScaleBar = false
    }
    
    private func setDefaultValue() {
        
        mapView.logoAlign = .rightTop
        mapView.maxZoomLevel = 18
        mapView.minZoomLevel = 15
        mapView.maxTilt = maxTilt
        mapView.contentInset = contentInset
        mapView.setLayerGroup(NMF_LAYER_GROUP_BUILDING, isEnabled: false)
        mapView.symbolScale = 0.5
        mapView.mapType = .navi
        
        mapView.adjustInterfaceStyle(style: UITraitCollection.current.userInterfaceStyle)
        
    }
    
    private func setDefaultLocation() {
        
        // 서울시청 좌표
        let baseLocation = NMGLatLng(lat: 37.56661, lng: 126.97839)
        
        let defaultCameraPosition = NMFCameraPosition(baseLocation, zoom: mapView.maxZoomLevel, tilt: maxTilt, heading: 0)
        mapView.moveCamera(NMFCameraUpdate(position: defaultCameraPosition))
        
        mapView.locationOverlay.location = baseLocation
        
    }
    
    private func setLocationOverlay() {
        
        mapView.locationOverlay.hidden = false
        mapView.locationOverlay.circleColor = .systemBlue.withAlphaComponent(0.1)
        mapView.locationOverlay.circleRadius = 50
        mapView.locationOverlay.icon = NMFOverlayImage(image: .naviIcon)
        
        locOverlaySize = CGSize(width: maxLocOverlaySize, height: maxLocOverlaySize)
        
    }
    
    private func setMapGesture() {
        
        let pan = UIPanGestureRecognizer().then {
            $0.addTarget(self, action: #selector(rotateHandler(_:)))
        }
        
        let pinch = UIPinchGestureRecognizer().then {
            $0.addTarget(self, action: #selector(zoomAndTiltHandler(_:)))
        }
        
        mapView.addGestureRecognizer(pan)
        mapView.addGestureRecognizer(pinch)
        mapView.isScrollGestureEnabled = false
        mapView.isZoomGestureEnabled = false
        mapView.isRotateGestureEnabled = false
        mapView.isTiltGestureEnabled = false
        mapView.isStopGestureEnabled = false
        
    }
    
    private func configureSubviews() {
        
        [circleButton, compass, cameraButton, geoTitleLabel, trackButton].forEach { addSubview($0) }
        
        setTopViews()
        
        setBottomViews()
        
    }
    
    private func setTopViews() {
        
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
        
        /*
         menuButton.snp.makeConstraints { make in
         make.top.equalTo(safeAreaLayoutGuide)
         make.trailing.equalTo(-12)
         }
         */
        
    }
    
    private func setBottomViews() {
        
        let buttonWidth = 50.0
        let inset = UIEdgeInsets(top: 0, left: 28, bottom: 60, right: 28)
        
        circleButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(inset)
            make.width.equalTo(buttonWidth)
            make.height.equalTo(circleButton.snp.width)
        }
        
        cameraButton.snp.makeConstraints { make in
            make.trailing.bottom.equalToSuperview().inset(inset)
            make.width.equalTo(buttonWidth)
            make.height.equalTo(circleButton.snp.width)
        }
        
        trackButton.snp.makeConstraints { make in
            make.leading.bottom.equalToSuperview().inset(inset)
            make.width.equalTo(buttonWidth)
            make.height.equalTo(trackButton.snp.width)
        }
        
        [circleButton, cameraButton, trackButton].forEach {
            $0.layer.cornerRadius = buttonWidth/2
        }
        
    }
    
    // MARK: - Action Handler Method
    
    @objc private func compassHanlder(_ sender: UITapGestureRecognizer) {
        
        trackButton.isSelected = false
        
        let update = NMFCameraUpdate(heading: 0)
        update.animationDuration = 0.3
        update.animation = .easeOut
        mapView.locationOverlay.heading = 0
        moveCameraBlockGesture(update) {
            //            print("나침반 초기화 완료")
        }
        
    }
    
    @objc private func rotateHandler(_ sender: UIPanGestureRecognizer) {
        
        let translation = sender.translation(in: mapView)
        let location = sender.location(in: mapView)
        print("panning --------------------------")
        print("translation:",translation)
        print("location:",location)
        
        if sender.state == .began {
            print("began")
            trackButton.isSelected = false
        } else if sender.state == .changed {
            // rotating map camera
            
            let bounds = mapView.bounds
            let vector1 = CGVector(dx: location.x - bounds.midX, dy: location.y - bounds.midY)
            let vector2 = CGVector(dx: vector1.dx + translation.x, dy: vector1.dy + translation.y)
            let angle1 = atan2(vector1.dx, vector1.dy)
            let angle2 = atan2(vector2.dx, vector2.dy)
            let delta = (angle2 - angle1) * 180.0 / Double.pi
            
            let param = NMFCameraUpdateParams()
            param.rotate(by: delta)
            let update = NMFCameraUpdate(params: param)
            
            mapView.moveCamera(update)
            //              mapView.locationOverlay.heading += delta
            
            
            //                print(delta)
        } else if sender.state == .ended {
            print("end")
        }
        
        sender.setTranslation(.zero, in: mapView)
        
    }
    
    @objc private func zoomAndTiltHandler(_ sender: UIPinchGestureRecognizer) {
        
        let zoom = currentZoom
        let tilt = currentTilt
        let size = locOverlaySize.width
        
        print("pinch-------------------------------------")
        print("scale:", sender.scale)
        print("zoom:", zoom)
        print("tilt:", tilt)

        let minZoom = mapView.minZoomLevel
        let maxZoom = mapView.maxZoomLevel
        
        let minSize = minLocOverlaySize
        let maxSize = maxLocOverlaySize
        
        if sender.state == .began {
            print("start")
            trackButton.isSelected = false

        } else if sender.state == .changed {
            
            let deltaZoom = sender.scale-1
            let deltaTilt = (maxTilt - minTilt) * deltaZoom / (maxZoom-minZoom)
            let deltaSize = (maxSize - minSize) * deltaZoom / (maxZoom - minZoom)
            
            // Camera Update
            let param = NMFCameraUpdateParams().then {
                $0.zoom(by: deltaZoom)
                
                if tilt + deltaTilt < minTilt {
                    $0.tilt(to: minTilt)
                } else {
                    $0.tilt(by: deltaTilt)
                }
                
            }
            
            let update = NMFCameraUpdate(params: param)
            mapView.moveCamera(update)
            
            // Location Overlay Update
            let newSize = size + deltaSize < minSize ? minSize : (size + deltaSize > maxSize ? maxSize : deltaSize + size)
            
            locOverlaySize = CGSize(width: newSize, height: newSize)
            

        } else if sender.state == .ended {
            print("ended")
        }
        
        sender.scale = 1
        
    }
    
    // MARK: - Helper Method
    
    func moveCameraBlockGesture(_ update: NMFCameraUpdate, completionHandler: @escaping () -> ()) {
        
        let gestures = mapView.gestureRecognizers
        
        gestures?.forEach{ $0.isEnabled = false }
        trackButton.isSelected = false
        
        mapView.moveCamera(update) { bool in
            print("카메라 전환 완료 👍👍👍👍👍", bool)
            gestures?.forEach{ $0.isEnabled = true }
            completionHandler()
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        let style = UITraitCollection.current.userInterfaceStyle
        mapView.adjustInterfaceStyle(style: style)
        circleOverlay.outlineColor = .secondaryLabel
        mapView.locationOverlay.icon = NMFOverlayImage(image: .naviIcon)
        
        
    }
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureMapView()
        configureSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Extension

extension MapView {
    
    var maxTilt: Double { 63 }
    
    var minTilt: Double { 13 }
    
    var contentInset: UIEdgeInsets {
        UIEdgeInsets(top: 0, left: 0, bottom: -UIScreen.main.bounds.height/2, right: 0)
    }
    
    var currentTilt: Double { mapView.cameraPosition.tilt }
    
    var currentZoom: Double { mapView.cameraPosition.zoom }
    
    var maxLocOverlaySize: CGFloat { 85 }
    
    var minLocOverlaySize: CGFloat { 40 }
    
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
