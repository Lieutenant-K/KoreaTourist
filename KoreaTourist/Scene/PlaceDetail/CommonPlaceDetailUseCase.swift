//
//  CommonPlaceDetailUseCase.swift
//  KoreaTourist
//
//  Created by 김윤수 on 10/21/23.
//

import Foundation
import Combine

final class CommonPlaceDetailUseCase {
    private let placeInfo: CommonPlaceInfo
    private let placeRepository = CommonPlaceRepository()
    private let userRepository = CommonUserRepository()
    private var cancellables = Set<AnyCancellable>()
    
    private let intro = PassthroughSubject<Intro?, Never>()
    private let detail = PassthroughSubject<DetailInformation?, Never>()
    private let extra = PassthroughSubject<ExtraPlaceInfo?, Never>()
    lazy var detailInformations = Publishers.CombineLatest3(self.intro, self.detail, self.extra)
    
    init(placeInfo: CommonPlaceInfo) {
        self.placeInfo = placeInfo
    }
    
    func tryFetchPlaceDetailInformation() {
        let id = self.placeInfo.contentId
        let contentType = self.placeInfo.contentType
        let detailType = contentType.detailInfoType
        
        self.fetchOrLoadIntro(id: id)
        self.fetchOrLoadDetail(id: id, contentType: contentType, detailType: detailType)
        self.fetchOrLoadExtra(id: id, contentType: contentType)
    }
}

extension CommonPlaceDetailUseCase {
    func commonPlaceInfo() -> AnyPublisher<CommonPlaceInfo, Never> {
        return Just(self.placeInfo).eraseToAnyPublisher()
    }
    
    func placeImages() -> AnyPublisher<PlaceImageInfo, NetworkError> {
        let id = self.placeInfo.contentId
        if let images = self.userRepository.load(type: PlaceImageInfo.self, contentId: id) {
            return Future<PlaceImageInfo, NetworkError> {
                $0(.success(images))
            }
            .eraseToAnyPublisher()
        } else {
            return self.placeRepository.placeImages(contentId: id)
                .handleEvents(receiveOutput: { [weak self] info in
                    self?.userRepository.save(object: info)
                })
                .eraseToAnyPublisher()
        }
    }
}

extension CommonPlaceDetailUseCase {
    private func fetchOrLoadIntro(id: Int) {
        if let intro = self.placeInfo.intro {
            self.intro.send(intro)
        } else {
            self.fetchIntroInfo(id: id)
        }
    }
    
    private func fetchIntroInfo(id: Int) {
        self.placeRepository.placeIntroInfo(contentId: id)
            .withUnretained(self)
            .sink { [weak self] in
                if case let .failure(error) = $0 {
                    print(error)
                    self?.intro.send(nil)
                }
            } receiveValue: {
                $0.intro.send($1)
                if let intro = $1 {
                    $0.userRepository.updateIntro(target: $0.placeInfo, with: intro)
                }
            }
            .store(in: &self.cancellables)
    }
    
    private func fetchOrLoadDetail(id: Int, contentType: ContentType, detailType: DetailInformation.Type) {
        if !self.userRepository.isExist(contentId: id, type: detailType) {
            self.fetchDetailInfo(id: id, contentType: contentType, detailType: detailType)
        } else if let detail = self.userRepository.load(type: detailType, contentId: id) as? DetailInformation {
            self.detail.send(detail)
        }
    }
    
    private func fetchDetailInfo(id: Int, contentType: ContentType, detailType: DetailInformation.Type) {
        self.placeRepository.placeDetailInfo(type: detailType, contentId: id, contentType: contentType)
            .withUnretained(self)
            .sink { [weak self] in
                if case let .failure(error) = $0 {
                    print(error)
                    self?.detail.send(nil)
                }
            } receiveValue: {
                $0.detail.send($1)
                if let detail = $1 {
                    $0.userRepository.save(object: detail)
                }
            }
            .store(in: &self.cancellables)
    }
    
    private func fetchOrLoadExtra(id: Int, contentType: ContentType) {
        if !self.userRepository.isExist(contentId: id, type: ExtraPlaceInfo.self) {
            self.fetchExtraInfo(id: id, contentType: contentType)
        } else if let extra = self.userRepository.load(type: ExtraPlaceInfo.self, contentId: id) {
            self.extra.send(extra)
        }
    }
    
    private func fetchExtraInfo(id: Int, contentType: ContentType) {
        self.placeRepository.placeExtraInfo(contentId: id, contentType: contentType)
            .withUnretained(self)
            .sink {[weak self] in
                if case let .failure(error) = $0 {
                    print(error)
                    self?.extra.send(nil)
                }
            } receiveValue: {
                $0.extra.send($1)
                if let extra = $1 {
                    $0.userRepository.save(object: extra)
                }
            }
            .store(in: &self.cancellables)
    }
}
