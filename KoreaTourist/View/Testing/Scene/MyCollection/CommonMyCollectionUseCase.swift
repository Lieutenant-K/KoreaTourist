//
//  CommonMyCollectionUseCase.swift
//  KoreaTourist
//
//  Created by 김윤수 on 1/7/24.
//

import Foundation
import Combine

final class CommonMyCollectionUseCase {
    private let placeRepository = CommonPlaceRepository()
    private let userRepository = CommonUserRepository()
    private var cancellables = Set<AnyCancellable>()
    
    let areaCodeList = PassthroughSubject<[AreaCode], Never>()
    let collectedPlaceList = PassthroughSubject<[CommonPlaceInfo], Never>()
    
    func tryFetchAreaCodeList() {
        self.fetchOrLoadAreaCodeList()
    }
    
    func tryFetchCollectedPlaceList() {
        let list = self.userRepository.load(type: CommonPlaceInfo.self)
        self.collectedPlaceList.send(list)
    }
}

extension CommonMyCollectionUseCase {
    private func fetchOrLoadAreaCodeList() {
        let list = self.userRepository.load(type: AreaCode.self)
        
        if list.isEmpty {
            self.fetchAreaCodeList()
        } else {
            self.areaCodeList.send(list)
        }
    }
    
    private func fetchAreaCodeList() {
        self.placeRepository.areaCodeList()
            .withUnretained(self)
            .sink(receiveCompletion: {
                if case let .failure(error) = $0 {
                    print(error)
                }
            }, receiveValue: { object, areaList in
                areaList.forEach {
                    object.userRepository.save(object: $0)
                }
                let areaCodeList = object.userRepository.load(type: AreaCode.self)
                object.areaCodeList.send(areaCodeList)
            })
            .store(in: &self.cancellables)
    }
}
