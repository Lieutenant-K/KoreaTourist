//
//  PopupViewModel.swift
//  KoreaTourist
//
//  Created by 김윤수 on 10/19/23.
//

import Foundation

import Combine

final class PopupViewModel {
    weak var coordinator: PopupCoordinator?
    private let placeInfo: CommonPlaceInfo
    
    init(placeInfo: CommonPlaceInfo) {
        self.placeInfo = placeInfo
    }
    
    struct Input {
        let viewDidLoadEvent: AnyPublisher<Void, Never>
        let okButtonTapEvent: AnyPublisher<Void, Never>
        let detailInfoButtonTapEvent : AnyPublisher<Void, Never>
    }
    
    struct Output {
        let title = CurrentValueSubject<String, Never>("")
        let description = CurrentValueSubject<String, Never>("")
        let imageURL = CurrentValueSubject<String, Never>("")
    }
    
    func transform(input: Input, cancellables: inout Set<AnyCancellable>) -> Output {
        let output = Output()
        
        input.viewDidLoadEvent
            .compactMap { [weak self] _ in self?.placeInfo }
            .sink {
                output.title.send($0.title)
                output.description.send([$0.addr1,$0.addr2].joined(separator: " "))
                output.imageURL.send($0.image)
            }
            .store(in: &cancellables)
        
        input.okButtonTapEvent
            .sink { [weak self] _ in
                self?.coordinator?.finish()
            }
            .store(in: &cancellables)
        
        input.detailInfoButtonTapEvent
            .compactMap { [weak self] _ in self?.placeInfo }
            .sink { [weak self] in
                self?.coordinator?.pushDetailPlaceInfoScene(place: $0)
            }
            .store(in: &cancellables)
        
        return output
    }
}
