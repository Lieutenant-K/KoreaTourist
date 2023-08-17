//
//  MapView.swift
//  KakaoMap
//
//  Created by 김윤수 on 2022/09/19.
//

import UIKit

import NMapsMap
import SnapKit

final class MapView: NMFNaverMapView {
    // MARK: - Properties
    private let buttonWidth: CGFloat = 50
    private var buttonInset = UIEdgeInsets(top: 0, left: 28, bottom: 60, right: 28)
    
    let localizedLabel = LocalizedTitleLabel()
    let compassView = NMFCompassView()
    let cameraModeButton = MapCameraModeButton(type: .system)
    let circleMenuButton = CircleMenuButton()
    let boundaryCircleOverlay = NMFCircleOverlay(NMGLatLng(lat: 0, lng: 0), radius: Circle.defaultRadius)
    lazy var trackButton = HeadTrackButton(location: mapView.locationOverlay)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureMapView()
        configureSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        let style = UITraitCollection.current.userInterfaceStyle
        
        mapView.adjustInterfaceStyle(style: style)
        
        boundaryCircleOverlay.outlineColor = .secondaryLabel
    }
}

// MARK: - Helper Method
extension MapView {
    private func configureMapView() {
        disableDefaultControl()
        setDefaultValue()
        setDefaultLocation()
        setLocationOverlay()
        setMapGesture()
    }
    
    private func disableDefaultControl() {
        self.showZoomControls = false
        self.showCompass = false
        self.showScaleBar = false
    }
    
    private func setDefaultValue() {
        self.mapView.logoAlign = .rightTop
        self.mapView.maxZoomLevel = 18
        self.mapView.minZoomLevel = 15
        self.mapView.maxTilt = self.maxTilt
        self.mapView.contentInset = self.contentInset
        self.mapView.setLayerGroup(NMF_LAYER_GROUP_BUILDING, isEnabled: false)
        self.mapView.symbolScale = 0.5
        self.mapView.mapType = .navi
        self.mapView.adjustInterfaceStyle(style: UITraitCollection.current.userInterfaceStyle)
    }
    
    private func setDefaultLocation() {
        // 서울시청 좌표
        let location = NMGLatLng(lat: 37.56661, lng: 126.97839)
        let position = NMFCameraPosition(location, zoom: mapView.maxZoomLevel, tilt: self.maxTilt, heading: 0)
        
        self.mapView.moveCamera(NMFCameraUpdate(position: position))
        self.mapView.locationOverlay.location = location
    }
    
    private func setLocationOverlay() {
        mapView.locationOverlay.hidden = false
        mapView.locationOverlay.circleColor = .systemBlue.withAlphaComponent(0.1)
        mapView.locationOverlay.circleRadius = 50
        mapView.locationOverlay.icon = NMFOverlayImage(image: .location)
        
        locOverlaySize = CGSize(width: maxLocOverlaySize, height: maxLocOverlaySize)
    }
    
    private func setMapGesture() {
        let pan = UIPanGestureRecognizer()
        pan.addTarget(self, action: #selector(rotateHandler(_:)))
        
        let pinch = UIPinchGestureRecognizer()
        pinch.addTarget(self, action: #selector(zoomAndTiltHandler(_:)))
        
        mapView.addGestureRecognizer(pan)
        mapView.addGestureRecognizer(pinch)
        mapView.isScrollGestureEnabled = false
        mapView.isZoomGestureEnabled = false
        mapView.isRotateGestureEnabled = false
        mapView.isTiltGestureEnabled = false
        mapView.isStopGestureEnabled = false
    }
    
    private func configureSubviews() {
        [circleMenuButton, compassView, cameraModeButton, localizedLabel, trackButton].forEach { addSubview($0) }
        
        // compass
        let tap = UITapGestureRecognizer()
        tap.addTarget(self, action: #selector(compassHanlder(_:)))
        
        self.compassView.mapView = mapView
        self.compassView.gestureRecognizers = [tap]
        
        // circleOverlay
        self.boundaryCircleOverlay.fillColor = .clear
        self.boundaryCircleOverlay.outlineWidth = 2.5
        self.boundaryCircleOverlay.outlineColor = .secondaryLabel
        
        self.setTopViews()
        self.setBottomViews()
    }
    
    private func setTopViews() {
        self.compassView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.leading.equalTo(12)
        }
        
        self.localizedLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.leading.greaterThanOrEqualTo(20)
            $0.trailing.lessThanOrEqualTo(-20)
        }
    }
    
    private func setBottomViews() {
        circleMenuButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(self.buttonInset)
            $0.width.equalTo(self.buttonWidth)
            $0.height.equalTo(self.circleMenuButton.snp.width)
        }
        
        cameraModeButton.snp.makeConstraints {
            $0.trailing.bottom.equalToSuperview().inset(self.buttonInset)
            $0.width.equalTo(self.buttonWidth)
            $0.height.equalTo(self.cameraModeButton.snp.width)
        }
        
        trackButton.snp.makeConstraints {
            $0.leading.bottom.equalToSuperview().inset(self.buttonInset)
            $0.width.equalTo(self.buttonWidth)
            $0.height.equalTo(self.trackButton.snp.width)
        }
        
        [self.circleMenuButton, self.cameraModeButton, self.trackButton].forEach {
            $0.layer.cornerRadius = self.buttonWidth/2
        }
    }
    
    func moveCameraBlockGesture(_ update: NMFCameraUpdate, completionHandler: @escaping () -> ()) {
        let gestures = self.mapView.gestureRecognizers
        
        gestures?.forEach{ $0.isEnabled = false }
        trackButton.isSelected = false
        
        mapView.moveCamera(update) { bool in
            print("카메라 전환 완료 👍👍👍👍👍", bool)
            gestures?.forEach{ $0.isEnabled = true }
            completionHandler()
        }
    }
    
    func controlButtonState(enabled: Bool) {
        [trackButton, circleMenuButton, cameraModeButton].forEach {
            $0.isEnabled = enabled
        }
    }
}

// MARK: - Action Handler Method
extension MapView {
    @objc private func compassHanlder(_ sender: UITapGestureRecognizer) {
        let update = NMFCameraUpdate(heading: 0)
        update.animationDuration = 0.3
        update.animation = .easeOut
        
        trackButton.isSelected = false
        
        mapView.locationOverlay.heading = 0
        
        moveCameraBlockGesture(update){}
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
            let vector1 = CGVector(dx: location.x - bounds.midX, dy: location.y - 3*bounds.midY/2)
            let vector2 = CGVector(dx: vector1.dx + translation.x, dy: vector1.dy + translation.y)
            let angle1 = atan2(vector1.dx, vector1.dy)
            let angle2 = atan2(vector2.dx, vector2.dy)
            let delta = (angle2 - angle1) * 180.0 / Double.pi
            
            let param = NMFCameraUpdateParams()
            param.rotate(by: delta)
            
            let update = NMFCameraUpdate(params: param)
            
            mapView.moveCamera(update)
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
            let param = NMFCameraUpdateParams()
            param.zoom(by: deltaZoom)
            
            if tilt + deltaTilt < minTilt {
                param.tilt(to: minTilt)
            } else {
                param.tilt(by: deltaTilt)
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
}

// MARK: Landscape Method
extension MapView {
    func deviceOrientationDidChange(mode: CameraMode, orient: UIDeviceOrientation) {
        self.updateMapView(mode: mode)
        self.updateSubviews(orient: orient)
    }
    
    private func updateMapView(mode: CameraMode) {
        var location: NMGLatLng
        
        switch mode {
        case .select(let loc):
            location = loc
        default:
            location = mapView.locationOverlay.location
        }
        
        let update = NMFCameraUpdate(scrollTo: location)
        
        mapView.contentInset = mode == .navigate ? contentInset : .zero
        mapView.moveCamera(update)
    }
    
    private func updateSubviews(orient: UIDeviceOrientation) {
        self.updateTopViews(orient: orient)
        self.updateBottomViews(orient: orient)
    }
    
    private func updateTopViews(orient: UIDeviceOrientation){
        let top: CGFloat = orient == .portrait ? 0 : 12
        let left: CGFloat = orient == .portrait ? 12 : 28
        let inset = UIEdgeInsets(top: top, left: left, bottom: 0, right: 0)
        
        compassView.snp.updateConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).inset(inset)
            $0.leading.equalToSuperview().inset(inset)
        }
        localizedLabel.snp.updateConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).inset(inset)
        }
    }
    
    private func updateBottomViews(orient: UIDeviceOrientation) {
        let bottom: CGFloat = orient == .portrait ? 60 : 30
        self.buttonInset.bottom = bottom
        
        self.updateCircleButton(orient: orient)
        
        self.trackButton.snp.updateConstraints {
            $0.leading.bottom.equalToSuperview().inset(self.buttonInset)
        }
        
        if orient == .portrait {
            self.circleMenuButton.snp.remakeConstraints {
                $0.centerX.equalToSuperview()
                $0.bottom.equalToSuperview().inset(self.buttonInset)
                $0.width.equalTo(buttonWidth)
                $0.height.equalTo(circleMenuButton.snp.width)
            }
            
            self.cameraModeButton.snp.remakeConstraints {
                $0.trailing.bottom.equalToSuperview().inset(self.buttonInset)
                $0.width.equalTo(buttonWidth)
                $0.height.equalTo(cameraModeButton.snp.width)
            }
        } else {
            self.circleMenuButton.snp.remakeConstraints {
                $0.trailing.bottom.equalToSuperview().inset(self.buttonInset)
                $0.width.equalTo(buttonWidth)
                $0.height.equalTo(circleMenuButton.snp.width)
            }
            
            self.cameraModeButton.snp.remakeConstraints {
                $0.leading.equalTo(trackButton.snp.trailing).offset(self.buttonInset.left + buttonWidth/2)
                $0.bottom.equalToSuperview().inset(self.buttonInset)
                $0.width.equalTo(buttonWidth)
                $0.height.equalTo(cameraModeButton.snp.width)
            }
        }
    }
    
    private func updateCircleButton(orient: UIDeviceOrientation) {
        let end: Float = orient == .portrait ? 90 : 0
        let dist: Float = orient == .portrait ? 85 : 100
        
        self.circleMenuButton.startAngle = -90
        self.circleMenuButton.endAngle = end
        self.circleMenuButton.distance = dist
        self.circleMenuButton.subButtonsRadius = 20
        self.circleMenuButton.hideButtons(0)
    }
}

// MARK: - Constant

extension MapView {
    var maxTilt: Double { 63 }
    var minTilt: Double { 13 }
    var contentInset: UIEdgeInsets {
        UIEdgeInsets(top: 0, left: 0, bottom: -UIScreen.main.bounds.height/2, right: 0)
    }
    var currentTilt: Double { self.mapView.cameraPosition.tilt }
    var currentZoom: Double { self.mapView.cameraPosition.zoom }
    var maxLocOverlaySize: CGFloat { 60 }
    var minLocOverlaySize: CGFloat { 30 }
    var locOverlaySize: CGSize {
        get {
            let overlay = self.mapView.locationOverlay
            return CGSize(width: overlay.iconWidth, height: overlay.iconHeight)
        }
        set {
            self.mapView.locationOverlay.iconWidth = newValue.width
            self.mapView.locationOverlay.iconHeight = newValue.height
        }
    }
}
