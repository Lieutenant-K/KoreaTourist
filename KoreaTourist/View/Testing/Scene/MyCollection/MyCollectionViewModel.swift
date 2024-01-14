//
//  MyCollectionViewModel.swift
//  KoreaTourist
//
//  Created by 김윤수 on 1/7/24.
//

import Foundation
import Combine

final class MyCollectionViewModel {
    let useCase: CommonMyCollectionUseCase
    weak var coordinator: MyCollectionCoordinator?
    
    init(useCase: CommonMyCollectionUseCase) {
        self.useCase = useCase
    }
    
    typealias Item = MyCollectionViewController.Item
    
    struct Input {
        let viewDidLoadEvent: AnyPublisher<Void, Never>
        let closeButtonTapEvent: AnyPublisher<Void, Never>
        let settingButtonTapEvent: AnyPublisher<Void,Never>
        let worldMapButtonTapEvent: AnyPublisher<Void,Never>
        let didSelectItemAtEvent: AnyPublisher<Item, Never>
    }
    
    struct Output {
        let areaCodeList = CurrentValueSubject<[AreaCode], Never>([])
        let collectedPlaceList = CurrentValueSubject<[CommonPlaceInfo], Never>([])
    }
    
    func transform(input: Input, cancellables: inout Set<AnyCancellable>) -> Output {
        let output = Output()
        
        self.useCase.areaCodeList
            .sink {
                output.areaCodeList.send($0)
            }
            .store(in: &cancellables)
        
        self.useCase.collectedPlaceList
            .sink {
                output.collectedPlaceList.send($0)
            }
            .store(in: &cancellables)
        
        input.viewDidLoadEvent
            .withUnretained(self)
            .sink { object, _ in
                object.useCase.tryFetchAreaCodeList()
                object.useCase.tryFetchCollectedPlaceList()
            }
            .store(in: &cancellables)
        
        input.closeButtonTapEvent
            .withUnretained(self)
            .sink { object, _ in
                object.coordinator?.finish()
            }
            .store(in: &cancellables)
        
        input.didSelectItemAtEvent
            .withUnretained(self)
            .sink { object, item in
                switch item {
                case let .region(areaCode):
                    object.useCase.tryFetchCollectedPlaceList(filteredBy: areaCode)
                    break
                case let .place(info):
                    object.coordinator?.pushPlaceDetailScene(place: info)
                }
            }
            .store(in: &cancellables)
        
        return output
    }
}

extension MyCollectionViewModel {
    
}
