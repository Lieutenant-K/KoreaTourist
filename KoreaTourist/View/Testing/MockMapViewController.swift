//
//  MockMapViewController.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2023/05/20.
//

import UIKit
import Combine

import CombineCocoa
import NMapsMap
import SnapKit

final class MockMapViewController: UIViewController {
    private let mapView: MainMapView
    private let compassView: CompassView
    private let trackButton: HeadTrackButton
    private let cameraModeButton: MapCameraModeButton
    private let localizedLabel = LocalizedTitleLabel()
    private let circleMenuButton = CircleMenuButton()
    private let activityIndicator = MapActivityIndicator()
    private var markers: [PlaceMarker] = []
    private var viewModel = MapViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    init(map: MainMapView, compass: CompassView, headTrack: HeadTrackButton, camera: MapCameraModeButton) {
        self.mapView = map
        self.compassView = compass
        self.trackButton = headTrack
        self.cameraModeButton = camera
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bindViewModel()
        self.configureSubviews()
        self.observeCameraMoving()
    }
    
    private func bindViewModel() {
        let input = MapViewModel.Input(
            viewDidLoadEvent: Just(()).eraseToAnyPublisher(),
            headTrackButtonDidTapEvent: self.trackButton.tapPublisher,
            mapMenuButtonDidTapEvent: self.circleMenuButton.selectedMenu,
            cameraModeButtonDidTapEvent: self.cameraModeButton.tapPublisher,
            cameraIsChangingByModeEvent: self.mapView.cameraIsChangingByModeEvent)
        let output = viewModel.transform(input: input, cancellables: &self.cancellables)
        
        output.currentHeading
            .sink { [weak self] in
                self?.trackButton.headValue = $0
            }
            .store(in: &self.cancellables)
        
        output.currentLocation
            .map { NMGLatLng(lat: $0.latitude, lng: $0.longitude) }
            .sink { [weak self] pos in
                let update = NMFCameraUpdate(scrollTo: pos)
                update.reason = Int32(NMFMapChangedByLocation)
                
                self?.mapView.moveCamera(update)
                self?.mapView.locationOverlay.location = pos
                self?.markers.forEach { $0.distance = $0.position.distance(to: pos)}
            }
            .store(in: &self.cancellables)
        
        output.visibleMarkers
            .sink { [weak self] in
                self?.resetMarkers(with: $0)
                self?.mapView.showBoundary()
            }
            .store(in: &self.cancellables)
        
        output.isMarkerFilterOn
            .sink { [weak self] filter in
                self?.circleMenuButton.isFilterOn = filter
                self?.markers.forEach {
                    $0.hidden = filter && $0.isDiscovered
                }
            }
            .store(in: &self.cancellables)
        
        output.isLocationServiceAlertShowed
            .filter { $0 }
            .sink { [weak self] _ in
                let cancel = UIAlertAction(title: "확인", style: .cancel)
                let goSetting: UIAlertAction = .goSettingAction
                let title = "위치 서비스를 사용할 수 없어요!"
                let message = "설정에서 위치 서비스 사용 권한을 허용해주세요!"
                
                self?.showAlert(title: title, message: message, actions: [cancel, goSetting])
            }
            .store(in: &self.cancellables)
        
        output.isActivityIndicatorShowed
            .sink { [weak self] in
                guard let self = self else { return }
                
                if $0 { self.activityIndicator.show(in: self.view, animated: true) }
                else { self.activityIndicator.dismiss(animated: true) }
            }
            .store(in: &self.cancellables)
        
        output.currentCameraMode
            .sink { [weak self] in
                self?.cameraModeButton.switchMode(to: $0)
            }
            .store(in: &self.cancellables)
    }
}

extension MockMapViewController {
    private func resetMarkers(with markers: [PlaceMarker]) {
        self.markers.forEach { $0.mapView = nil }
        self.markers.removeAll()
        self.markers = markers
        self.markers.forEach { $0.mapView = self.mapView }
    }
    
    private func observeCameraMoving() {
        self.mapView.cameraIsChangingByModeEvent
            .map { !$0 }
            .sink { [weak self] in
                self?.trackButton.isEnabled = $0
                self?.circleMenuButton.isEnabled = $0
                self?.cameraModeButton.isEnabled = $0
                if !$0 {
                    self?.circleMenuButton.hideButtons(0.3)
                }
            }
            .store(in: &self.cancellables)
    }
}

extension MockMapViewController {
    private var buttonWidth: CGFloat {
        return 50
    }
    private var buttonInset: UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 28, bottom: 60, right: 28)
    }
    
    private func configureSubviews() {
        self.view.addSubview(self.mapView)
        self.mapView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        self.view.addSubview(self.localizedLabel)
        self.localizedLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(self.view.safeAreaLayoutGuide)
            $0.leading.greaterThanOrEqualTo(20)
            $0.trailing.lessThanOrEqualTo(-20)
        }
        
        self.view.addSubview(self.compassView)
        self.compassView.mapView = self.mapView
        self.compassView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide)
            $0.leading.equalTo(12)
        }
        
        self.view.addSubview(self.circleMenuButton)
        self.circleMenuButton.layer.cornerRadius = self.buttonWidth/2
        self.circleMenuButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(self.buttonInset)
            $0.width.equalTo(self.buttonWidth)
            $0.height.equalTo(self.circleMenuButton.snp.width)
        }
        
        self.view.addSubview(self.cameraModeButton)
        self.cameraModeButton.layer.cornerRadius = self.buttonWidth/2
        self.cameraModeButton.snp.makeConstraints {
            $0.trailing.bottom.equalToSuperview().inset(self.buttonInset)
            $0.width.equalTo(self.buttonWidth)
            $0.height.equalTo(self.cameraModeButton.snp.width)
        }
        
        self.view.addSubview(self.trackButton)
        self.trackButton.layer.cornerRadius = self.buttonWidth/2
        self.trackButton.snp.makeConstraints {
            $0.leading.bottom.equalToSuperview().inset(self.buttonInset)
            $0.width.equalTo(self.buttonWidth)
            $0.height.equalTo(self.trackButton.snp.width)
        }
    }
}
