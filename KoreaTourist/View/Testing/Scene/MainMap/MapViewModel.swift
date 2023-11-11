//
//  MapViewModel.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2023/05/21.
//

import Foundation
import Combine

final class MapViewModel {
    private let useCase: CommonMapUseCase
    private var isMarkerFilterEnabled = false
    private var previousCamera: MapCameraMode? = nil
    private var currentCamera: MapCameraMode = .navigation
    weak var coordinator: MainMapCoordinator?
    
    init(useCase: CommonMapUseCase) {
        self.useCase = useCase
    }
    
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
        let toastMessage = PassthroughSubject<String, Never>()
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
                    self.isMarkerFilterEnabled.toggle()
                    let message = "미발견 장소만 보기: " + (self.isMarkerFilterEnabled ? "켜짐" : "꺼짐")
                    output.isMarkerFilterOn.send(self.isMarkerFilterEnabled)
                    output.toastMessage.send(message)
                case .userInfo:
                    self.coordinator?.pushPlaceCollectionScene()
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
            .compactMap { [weak self] in self?.createMarkers(places: $0, cameraMode: output.currentCameraMode, message: output.toastMessage) }
            .handleEvents(receiveOutput: {
                output.currentCameraMode.send(.search)
                output.toastMessage.send("\($0.count)개의 장소를 발견했습니다!")
            })
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
        
        self.useCase.errorMessage
            .subscribe(output.toastMessage)
            .store(in: &cancellables)
        
        return output
    }
}

extension MapViewModel {
    private func createMarkers(places: [CommonPlaceInfo], cameraMode: PassthroughSubject<MapCameraMode, Never>, message: PassthroughSubject<String, Never>) -> [PlaceMarker] {
        let markers = places.map { PlaceMarker(place: $0) }
        markers.forEach {
            $0.hidden = $0.isDiscovered && self.isMarkerFilterEnabled //self.isMarkerFiltered.value
            $0.markerDidTapEvent.sink { [weak self] in
                self?.handleMarkerTapEvent(target: $0, cameraMode: cameraMode, message: message)
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
    
    
    private func handleMarkerTapEvent(target: PlaceMarker, cameraMode: PassthroughSubject<MapCameraMode, Never>, message: PassthroughSubject<String, Never>) {
        let coordinate = Coordinate(latitude: target.position.lat, longitude: target.position.lng)
        let mode: MapCameraMode = .select(coordinate)
        
        if self.currentCamera == mode {
            self.presentDiscoverFlow(marker: target, failureMessage: message)
        } else {
            self.changeCameraMode(to: mode)
            cameraMode.send(mode)
        }
    }
    
    
    /// 새로운 장소를 발견하거나 발견된 장소를 보여주기 위해 다른 화면으로 전환하는 메서드
    /// - Parameters:
    ///   - marker: 선택한 장소의 마커 객체
    ///   - failureMessage: 장소를 발견할 수 없을 때 유저에게 보여줄 메시지를 방핼할 Publisher 객체
    private func presentDiscoverFlow(marker: PlaceMarker, failureMessage: PassthroughSubject<String, Never>) {
        if marker.placeInfo.isDiscovered {
            self.coordinator?.pushDetailPlaceInfoScene(place: marker.placeInfo)
        } else if marker.distance <= PlaceMarker.minimumDistance {
            self.coordinator?.showPlaceDiscoverAlert(place: marker.placeInfo) { [weak self] in
                self?.useCase.tryToDiscoverPlace(id: marker.placeInfo.contentId) {
                    self?.coordinator?.pushDiscoverPopupScene(place: marker.placeInfo)
                }
                marker.updateMarkerAppearnce()
            }
        } else {
            let title = "아직 발견할 수 없습니다. \(Int(PlaceMarker.minimumDistance))m 이내로 접근해주세요."
            failureMessage.send(title)
        }
    }
}
