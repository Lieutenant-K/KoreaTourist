//
//  CommonPlaceRepository.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2023/05/23.
//

import Foundation

import Combine

final class CommonPlaceRepository {
    private let networkService = NetworkManager()
    private var cancellables = Set<AnyCancellable>()
    let isNetworking = PassthroughSubject<Bool, Never>()
    let nearbyPlaces = PassthroughSubject<[CommonPlaceInfo], Never>()
    
    func fetchPlacesNearby(coordinate: Coordinate) {
        let circle = Circle(x: coordinate.longitude, y: coordinate.latitude, radius: Circle.defaultRadius)
        self.isNetworking.send(true)
        self.networkService.request(router: .location(circle), type: CommonPlaceInfo.self)
            .sink { [weak self] completion in
                self?.isNetworking.send(false)
                switch completion {
                case let .failure(error):
                    print(error)
                case .finished:
                    break
                }
            } receiveValue: { [weak self] in
                self?.nearbyPlaces.send($0)
            }
            .store(in: &self.cancellables)
    }
}
