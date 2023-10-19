//
//  MapUseCase.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2023/05/22.
//

import Foundation
import Combine

final class CommonMapUseCase {
    private let locationServcie = LocationManager()
    private let placeRepository = CommonPlaceRepository()
    private let userRepository = UserPlaceRepository()
    private var cancellables = Set<AnyCancellable>()
    let isTracking = CurrentValueSubject<Bool, Never>(false)
    let places = PassthroughSubject<[CommonPlaceInfo], Never>()
    let coordinate = CurrentValueSubject<Coordinate, Never>(.seoul)
    let errorMessage = PassthroughSubject<String, Never>()
    
    func observeNearbyPlaces() {
        self.placeRepository.nearbyPlaces
            .map { $0.sorted(by: { left, right in left.dist < right.dist }) }
            .compactMap { [weak self] in self?.userRepository.updatePlaces(places: $0) }
            .subscribe(self.places)
            .store(in: &self.cancellables)
    }
    
    func observeUserLocation() {
        self.locationServcie.locationPublisher
            .map { Coordinate(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude) }
            .subscribe(self.coordinate)
            .store(in: &self.cancellables)
    }
    
    func tryFetchNearbyPlaces() {
        self.placeRepository.fetchPlacesNearby(coordinate: self.coordinate.value)
    }
    
    func shouldTrackHeading() {
        if self.locationServcie.headingAvailable {
            self.toggleHeadTracking()
        } else {
            self.errorMessage.send("방향 추적 기능을 사용할 수 없습니다.")
        }
    }
    
    func heading() -> AnyPublisher<Double, Never> {
        self.locationServcie.headingPublisher.map { $0.trueHeading }.eraseToAnyPublisher()
    }
    
    func locationServiceStatus() -> AnyPublisher<Bool, Never> {
        self.locationServcie.isAuthorized.eraseToAnyPublisher()
    }
    
    func networkingStatus() -> AnyPublisher<Bool, Never> {
        self.placeRepository.isNetworking.eraseToAnyPublisher()
    }
    
    func toggleLocationUpdating(isEnabled: Bool) {
        if isEnabled {
            self.locationServcie.startUpdatingLocation()
        } else {
            self.locationServcie.stopUpdatingLocation()
        }
    }
    
    func tryToDiscoverPlace(id: Int, completionHandler: () -> ()) {
        self.userRepository.discoverPlace(with: id, completion: completionHandler)
    }
}

extension CommonMapUseCase {
    private func toggleHeadTracking() {
        if self.isTracking.value {
            self.locationServcie.stopUpdatingHeading()
            self.isTracking.send(false)
        }
        else {
            self.locationServcie.startUpdatingHeading()
            self.isTracking.send(true)
        }
    }
}
