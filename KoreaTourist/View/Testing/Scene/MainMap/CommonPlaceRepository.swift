//
//  CommonPlaceRepository.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2023/05/23.
//

import Foundation

import Combine

/// 소개, 상세, 추가, 이미지 등 **장소**에 관한 데이터를 불러오는 객체
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

extension CommonPlaceRepository {
    func placeDetailInfo<T: DetailInformation>(type: T.Type, contentId: Int, contentType: ContentType) -> AnyPublisher<DetailInformation?, NetworkError> {
        self.isNetworking.send(true)
        return self.networkService.request(router: .typeInfo(contentId, contentType), type: T.self)
            .handleEvents(receiveCompletion: { [weak self] _ in
                self?.isNetworking.send(false)
            })
            .map { $0.first }
            .eraseToAnyPublisher()
    }
    
    func placeIntroInfo(contentId: Int) -> AnyPublisher<Intro?, NetworkError> {
        self.isNetworking.send(true)
        return self.networkService.request(router: .commonInfo(contentId), type: Intro.self)
            .handleEvents(receiveCompletion: { [weak self] _ in
                self?.isNetworking.send(false)
            })
            .map { $0.first }
            .eraseToAnyPublisher()
    }
    
    func placeExtraInfo(contentId: Int, contentType: ContentType) -> AnyPublisher<ExtraPlaceInfo?, NetworkError> {
        self.isNetworking.send(true)
        return self.networkService.request(router: .extraInfo(contentId, contentType), type: ExtraPlaceElement.self)
            .handleEvents(receiveCompletion: { [weak self] _ in
                self?.isNetworking.send(false)
            })
            .map { ExtraPlaceInfo(id: contentId, infoList: $0) }
            .map { $0.list.isEmpty ? nil : $0 }
            .eraseToAnyPublisher()
    }
}

extension CommonPlaceRepository {
    func placeImages(contentId: Int) -> AnyPublisher<PlaceImageInfo, NetworkError> {
        self.isNetworking.send(true)
        return self.networkService.request(router: .detailImage(contentId), type: PlaceImage.self)
            .handleEvents(receiveCompletion: { [weak self] _ in
                self?.isNetworking.send(false)
            })
            .map { PlaceImageInfo(id: contentId, imageList: $0) }
            .eraseToAnyPublisher()
    }
}
