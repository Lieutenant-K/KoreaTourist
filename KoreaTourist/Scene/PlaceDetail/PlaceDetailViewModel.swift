//
//  PlaceDetailViewModel.swift
//  KoreaTourist
//
//  Created by 김윤수 on 11/12/23.
//

import Foundation

import Combine

final class PlaceDetailViewModel {
    private let useCase: CommonPlaceDetailUseCase
    weak var coordinator: PlaceDetailCoordinator?
    
    init(useCase: CommonPlaceDetailUseCase) {
        self.useCase = useCase
    }
    
    struct Input {
        let mapViewTabEvent: AnyPublisher<Void, Never>
        let closeButtonTapEvent: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let placeInfo = CurrentValueSubject<PlaceInfo?, Never>(nil)
        let placeImages = CurrentValueSubject<[PlaceImage], Never>([])
    }
    
    func transform(input: Input, cancellables: inout Set<AnyCancellable>) -> Output {
        let output = Output()
        
        input.closeButtonTapEvent
            .withUnretained(self)
            .sink { object, _ in
                object.coordinator?.finish()
            }
            .store(in: &cancellables)
        
        input.mapViewTabEvent
            .withUnretained(self)
            .map { object, _ in object.useCase.commonPlaceInfo() }
            .switchToLatest()
            .withUnretained(self)
            .sink {
                $0.coordinator?.presentDiscoverdMapScene(place: $1)
            }
            .store(in: &cancellables)
        
        self.useCase.commonPlaceInfo()
            .map {
                PlaceInfo(
                    id: $0.contentId,
                    title: $0.title,
                    thumbnailImageURL: $0.image,
                    address: "\($0.addr1)\n\($0.addr2)",
                    discoverDate: $0.discoverDate,
                    position: $0.position.coordinate)
            }
            .sink {
                output.placeInfo.send($0)
            }
            .store(in: &cancellables)
        
        self.useCase.placeImages()
            .map { $0.images }
            .catch { _ in Just([]) }
            .sink {
                output.placeImages.send($0)
            }
            .store(in: &cancellables)
        
        return output
    }
}

extension PlaceDetailViewModel {
    struct PlaceInfo {
        let id: Int
        let title: String
        let thumbnailImageURL: String
        let address: String
        let discoverDate: Date?
        let position: Coordinate
    }
}
