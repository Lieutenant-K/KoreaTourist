//
//  BaseMapView.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2023/05/20.
//

import Foundation
import Combine

import NMapsMap

final class MainMapView: NMFMapView {
    private let boundaryOverlay = NMFCircleOverlay(.invalid(), radius: 0)
    private let cameraChangingByModeSubject = PassthroughSubject<Bool, Never>()
    var cameraIsChangingByModeEvent: AnyPublisher<Bool, Never> {
        self.cameraChangingByModeSubject.eraseToAnyPublisher()
    }
//    let cameraModeDidChangeEvent = PassthroughSubject<Void, Never>()
    
    /// 카메라 이동 중 제스처 비활성화 With 핸들러
    func moveCameraGestureDisabled(_ cameraUpdate: NMFCameraUpdate, completion: ((Bool) -> Void)? = nil) {
        self.gestureRecognizers?.forEach { $0.isEnabled = false }
        super.moveCamera(cameraUpdate) {
            completion?($0)
            self.gestureRecognizers?.forEach { $0.isEnabled = true }
        }
    }
    
    func showBoundary() {
        self.boundaryOverlay.center = self.locationOverlay.location
        self.boundaryOverlay.mapView = self
    }
    
    func changeLocOverlaySize(size: CGFloat) {
        self.locationOverlay.iconWidth = size
        self.locationOverlay.iconHeight = size
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureLocationOverlay()
        self.configureMap()
        self.setDefaultLocation()
        self.configureGesture()
        self.configureBoundary()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MainMapView: DynamicCameraModeMap {
    func changeCameraMode(to mode: MapCameraMode) {
        let inset = mode.inset == .default ? self.defaultContentInset : .zero
        let param = self.cameraModeParameter(config: mode.config)
        let overlaySize = self.locOveraySize(from: mode.config.zoom)
        let update = NMFCameraUpdate(params: param)
        update.reason = MapCameraChangeReason.byMode.rawValue
        update.animation = .easeOut
        update.animationDuration = 0.7
        self.contentInset = inset
        
        self.moveCameraGestureDisabled(update)
        self.changeLocOverlaySize(size: overlaySize)
        
//        if let pos = mode.position {
//            let inset: UIEdgeInsets = mode.isCenterd ? .zero : self.mapView.defaultContentInset
//            let tilt = mode.isClosed ? self.mapView.maxTilt : self.mapView.minTilt
//            let zoom = mode.isClosed ? self.mapView.maxZoomLevel : self.mapView.minZoomLevel
//            let size = mode.isClosed ? self.mapView.maxLocationOverlaySize : self.mapView.minLocationOverlaySize
//            let param = NMFCameraUpdateParams()
//            let update = NMFCameraUpdate(params: param)
//            let buttons = [self.trackButton, self.circleMenuButton, self.cameraModeButton]
//            
//            param.tilt(to: tilt)
//            param.zoom(to: zoom)
//            param.scroll(to: pos)
//            update.animation = .easeOut
//            update.animationDuration = 0.7
//            
//            if self.circleMenuButton.buttonsIsShown() {
//                self.circleMenuButton.hideButtons(0.3)
//            }
//            
//            buttons.forEach { $0.isEnabled = false }
//            self.mapView.contentInset = inset
//            self.mapView.changeLocationOverlaySize(size: size)
//            self.mapView.moveCameraGestureDisabled(update) { _ in
//                buttons.forEach { $0.isEnabled = true }
//            }
//        }
    }
    
    private func locOveraySize(from zoom: MapCameraMode.Configuration.ValueType) -> Double {
        switch zoom {
        case .min:
            return self.minLocOverlaySize
        case .max:
            return self.maxLocOverlaySize
        case .custom(let size):
            return size
        }
    }
}

extension MainMapView: NMFMapViewCameraDelegate {
    func mapView(_ mapView: NMFMapView, cameraWillChangeByReason reason: Int, animated: Bool) {
        if Int32(reason) == MapCameraChangeReason.byMode.rawValue {
            self.cameraChangingByModeSubject.send(true)
        }
    }
    
    func mapView(_ mapView: NMFMapView, cameraDidChangeByReason reason: Int, animated: Bool) {
        if Int32(reason) == MapCameraChangeReason.byMode.rawValue {
            self.cameraChangingByModeSubject.send(false)
        }
    }
}

extension MainMapView: HeadTrackableMap {
    func changeHead(to: Double) {
        let update = NMFCameraUpdate(heading: to)
        update.reason = Int32(NMFMapChangedByLocation)
        
        self.moveCamera(update)
        self.locationOverlay.heading = to
    }
}

extension MainMapView: HeadResetableMap {
    func resetHeading() {
        let update = NMFCameraUpdate(heading: 0)
        update.animationDuration = 0.3
        update.animation = .easeOut
        update.reason = Int32(NMFMapChangedByControl)
        
        self.locationOverlay.heading = 0
        self.moveCameraGestureDisabled(update)
    }
}

extension MainMapView {
    private func configureGesture() {
        let pan = UIPanGestureRecognizer()
        let pinch = UIPinchGestureRecognizer()
        pan.addTarget(self, action: #selector(self.rotateHandler(_:)))
        pinch.addTarget(self, action: #selector(self.zoomAndTiltHandler(_:)))

        self.addGestureRecognizer(pan)
        self.addGestureRecognizer(pinch)
        self.isScrollGestureEnabled = false
        self.isZoomGestureEnabled = false
        self.isRotateGestureEnabled = false
        self.isTiltGestureEnabled = false
        self.isStopGestureEnabled = false
    }

    private func configureLocationOverlay() {
        self.locationOverlay.hidden = false
        self.locationOverlay.circleColor = .systemBlue.withAlphaComponent(0.1)
        self.locationOverlay.circleRadius = 50
        self.locationOverlay.icon = NMFOverlayImage(image: .location)
        self.locationOverlay.iconWidth = self.maxLocOverlaySize
        self.locationOverlay.iconHeight = self.maxLocOverlaySize
        self.locationOverlay.globalZIndex = 2
    }
    
    private func configureBoundary() {
        self.boundaryOverlay.fillColor = .clear
        self.boundaryOverlay.outlineWidth = 2.5
        self.boundaryOverlay.outlineColor = .secondaryLabel
        self.boundaryOverlay.radius = Circle.defaultRadius
    }
    
    private func setDefaultLocation() {
        // 서울시청 좌표
        let location = NMGLatLng(lat: 37.56661, lng: 126.97839)
        let position = NMFCameraPosition(location, zoom: self.maxZoomLevel, tilt: self.maxTilt, heading: 0)
        
        self.moveCamera(NMFCameraUpdate(position: position))
        self.locationOverlay.location = location
    }
    
    var defaultContentInset: UIEdgeInsets {
        UIEdgeInsets(top: 0, left: 0, bottom: -UIScreen.main.bounds.height/2, right: 0)
    }
    
    private func configureMap() {
        self.addCameraDelegate(delegate: self)
        self.logoAlign = .rightTop
        self.maxZoomLevel = 18
        self.minZoomLevel = 15
        self.maxTilt = 63
        self.contentInset = self.defaultContentInset
        self.setLayerGroup(NMF_LAYER_GROUP_BUILDING, isEnabled: false)
        self.symbolScale = 0.5
        self.mapType = .navi
        self.adjustInterfaceStyle(style: UITraitCollection.current.userInterfaceStyle)
    }
}

extension MainMapView {
    var minTilt: Double {
        return 13
    }
    var minLocOverlaySize: Double {
        return 30
    }
    var maxLocOverlaySize: Double {
        return 60
    }
    
    @objc private func rotateHandler(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: self)
        let location = sender.location(in: self)

        if sender.state == .began { }
        else if sender.state == .changed {
            // rotating map camera
            let bounds = self.bounds
            let vector1 = CGVector(dx: location.x - bounds.midX, dy: location.y - 3*bounds.midY/2)
            let vector2 = CGVector(dx: vector1.dx + translation.x, dy: vector1.dy + translation.y)
            let angle1 = atan2(vector1.dx, vector1.dy)
            let angle2 = atan2(vector2.dx, vector2.dy)
            let delta = (angle2 - angle1) * 180.0 / Double.pi
            
            let param = NMFCameraUpdateParams()
            let update = NMFCameraUpdate(params: param)
            
            param.rotate(by: delta)
            update.reason = Int32(NMFMapChangedByGesture)
            
            self.moveCamera(update)
        }
        else if sender.state == .ended { }
        
        sender.setTranslation(.zero, in: self)
    }
    
    @objc private func zoomAndTiltHandler(_ sender: UIPinchGestureRecognizer) {
        let tilt = self.cameraPosition.tilt
        let size = self.locationOverlay.iconWidth
        
        let minZoom = self.minZoomLevel
        let maxZoom = self.maxZoomLevel
        let minSize = self.minLocOverlaySize
        let maxSize = self.maxLocOverlaySize
        
        if sender.state == .began { }
        else if sender.state == .changed {
            let deltaZoom = sender.scale-1
            let deltaTilt = (maxTilt - minTilt) * deltaZoom / (maxZoom - minZoom)
            let deltaSize = (maxSize - minSize) * deltaZoom / (maxZoom - minZoom)
            
            // Camera Update
            let param = NMFCameraUpdateParams()
            let update = NMFCameraUpdate(params: param)
            let newSize = size + deltaSize < minSize ? minSize : (size + deltaSize > maxSize ? maxSize : deltaSize + size)
            
            param.zoom(by: deltaZoom)
            if tilt + deltaTilt < minTilt {
                param.tilt(to: minTilt)
            } else {
                param.tilt(by: deltaTilt)
            }
            update.reason = Int32(NMFMapChangedByGesture)
            
            self.moveCamera(update)
            self.changeLocOverlaySize(size: newSize)
        }
        else if sender.state == .ended { }
        
        sender.scale = 1
    }
}

enum MapCameraChangeReason: Int32 {
    case byLocation = -3
    case byControl
    case byGesture
    case byDeveloper
    case byMode
    case none
}
