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
    
    /// 위치 좌표 근처의 장소 정보 가져오기
    func nearbyPlaces(coordinate: Coordinate) -> AnyPublisher<[CommonPlaceInfo], NetworkError> {
        let circle = Circle(x: coordinate.longitude, y: coordinate.latitude, radius: Circle.defaultRadius)
        self.isNetworking.send(true)
        return self.networkService.request(router: .location(circle), type: CommonPlaceInfo.self)
            .handleEvents(receiveCompletion: { [weak self] _ in
                self?.isNetworking.send(false)
            })
            .eraseToAnyPublisher()
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

extension CommonPlaceRepository {
    func areaCodeList() -> AnyPublisher<[AreaCode], NetworkError> {
        self.isNetworking.send(true)
        return self.networkService.request(router: .areaCode, type: AreaCode.self)
            .handleEvents(receiveCompletion: { [weak self] _ in
                self?.isNetworking.send(false)
            })
            .eraseToAnyPublisher()
    }
}
