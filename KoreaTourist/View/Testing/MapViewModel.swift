//
//  MapViewModel.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2023/05/21.
//

import Foundation
import Combine

final class MapViewModel {
    private let useCase = CommonMapUseCase()
    private let isMarkerFiltered = CurrentValueSubject<Bool, Never>(false)
    private var previousCamera: MapCameraMode? = nil
    private var currentCamera: MapCameraMode = .navigation
    
    struct Input {
        let viewDidLoadEvent: AnyPublisher<Void, Never>
        let headTrackButtonDidTapEvent: AnyPublisher<Void, Never>
        let mapMenuButtonDidTapEvent: AnyPublisher<MapMenu, Never>
        let cameraModeButtonDidTapEvent: AnyPublisher<Void, Never>
        let cameraIsChangingByModeEvent: AnyPublisher<Bool, Never>
    }
    
    struct Output {
        let currentHeading = PassthroughSubject<Double, Never>()
        let currentLocation = PassthroughSubject<Coordinate, Never>()
        let visibleMarkers = PassthroughSubject<[PlaceMarker], Never>()
        let isHeadTrackOn = PassthroughSubject<Bool, Never>()
        let isMarkerFilterOn = PassthroughSubject<Bool, Never>()
        let isLocationServiceAlertShowed = PassthroughSubject<Bool, Never>()
        let isActivityIndicatorShowed = PassthroughSubject<Bool, Never>()
        let currentCameraMode = PassthroughSubject<MapCameraMode, Never>()
    }
    
    func transform(input: Input, cancellables: inout Set<AnyCancellable>) -> Output {
        let output = Output()
        
        input.viewDidLoadEvent
            .sink { [weak self] _ in
                self?.useCase.observeNearbyPlaces()
                self?.useCase.observeUserLocation()
            }
            .store(in: &cancellables)
        
        input.headTrackButtonDidTapEvent
            .sink { [weak self] _ in
                self?.useCase.shouldTrackHeading()
            }
            .store(in: &cancellables)
        
        input.mapMenuButtonDidTapEvent
            .sink { [weak self] in
                guard let self = self else { return }
                switch $0 {
                case .search:
                    self.useCase.tryFetchNearbyPlaces()
                case .vision:
                    let isFiltered = !self.isMarkerFiltered.value
                    self.isMarkerFiltered.send(isFiltered)
                case .userInfo:
                    break
                }
            }
            .store(in: &cancellables)
        
        input.cameraModeButtonDidTapEvent
            .sink { [weak self] _ in
                let previous = self?.previousCamera
                self?.changeCameraMode(to: previous)
            }
            .store(in: &cancellables)
        
        input.cameraIsChangingByModeEvent
            .map { !$0 }
            .sink { [weak self] in
                if case .select = self?.currentCamera {
                    self?.useCase.toggleLocationUpdating(isEnabled: false)
                } else {
                    self?.useCase.toggleLocationUpdating(isEnabled: $0)
                }
            }
            .store(in: &cancellables)
        
        self.useCase.heading()
            .subscribe(output.currentHeading)
            .store(in: &cancellables)
        
        self.useCase.coordinate
            .subscribe(output.currentLocation)
            .store(in: &cancellables)
        
        self.useCase.places
            .compactMap { [weak self] in self?.createMarkers(places: $0, cameraMode: output.currentCameraMode) }
            .handleEvents(receiveOutput: { _ in output.currentCameraMode.send(.search) })
            .subscribe(output.visibleMarkers)
            .store(in: &cancellables)
        
        self.useCase.isTracking
            .subscribe(output.isHeadTrackOn)
            .store(in: &cancellables)
        
        self.useCase.locationServiceStatus()
            .map { !$0 }
            .subscribe(output.isLocationServiceAlertShowed)
            .store(in: &cancellables)
        
        self.useCase.networkingStatus()
            .subscribe(output.isActivityIndicatorShowed)
            .store(in: &cancellables)
        
        self.isMarkerFiltered
            .subscribe(output.isMarkerFilterOn)
            .store(in: &cancellables)
        
        return output
    }
}

extension MapViewModel {
    private func createMarkers(places: [CommonPlaceInfo], cameraMode: PassthroughSubject<MapCameraMode, Never>) -> [PlaceMarker] {
        let markers = places.map { PlaceMarker(place: $0) }
        markers.forEach {
            $0.hidden = $0.isDiscovered && self.isMarkerFiltered.value
            $0.markerDidTapEvent.sink { [weak self] in
                self?.handleMarkerTapEvent(target: $0, cameraMode: cameraMode)
            }
            .store(in: &$0.cancellables)
        }
        return markers
    }
    
    private func changeCameraMode(to mode: MapCameraMode?) {
        guard let mode else { return }

        switch mode {
        case .navigation:
            self.previousCamera = .search
        case .search:
            self.previousCamera = .navigation
        case .select(_):
            let current = self.currentCamera
            if current == .search || current == .navigation {
                self.previousCamera = current
            }
        }
        self.currentCamera = mode
    }
    
    private func handleMarkerTapEvent(target: PlaceMarker, cameraMode: PassthroughSubject<MapCameraMode, Never>) {
        let coordinate = Coordinate(latitude: target.position.lat, longitude: target.position.lng)
        let mode: MapCameraMode = .select(coordinate)
        
        if self.currentCamera == mode {
            self.presentDiscoverFlow(marker: target)
        } else {
            self.changeCameraMode(to: mode)
            cameraMode.send(mode)
        }
    }
    
    private func presentDiscoverFlow(marker: PlaceMarker) {
        if marker.placeInfo.isDiscovered {
//            let sub = SubInfoViewController(place: marker.placeInfo)
//            let main = MainInfoViewController(place: marker.placeInfo, subInfoVC: sub)
//            let vc = PlaceInfoViewController(place: marker.placeInfo, mainInfoVC: main)
//            let navi = UINavigationController(rootViewController: vc)
//            navi.modalPresentationStyle = .fullScreen
//            present(navi, animated: true)
//            return
        }
        
        if marker.distance <= PlaceMarker.minimumDistance {
//            let ok = UIAlertAction(title: "네", style: .cancel) { [weak self] _ in
//                self?.discoverPlace(about: marker)
//            }
//            let cancel = UIAlertAction(title: "아니오", style: .default)
//            let actions = [cancel, ok]
//            
//            showAlert(title: "이 장소를 발견하시겠어요?", actions: actions)
        } else {
//            naverMapView.makeToast("\(Int(PlaceMarker.minimumDistance))m 이내로 접근해주세요", point: .markerTop, title: "아직 발견할 수 없어요!", image: nil, completion: nil)
        }
    }
}
