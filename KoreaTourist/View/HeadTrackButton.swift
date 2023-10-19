//
//  HeadTrackButton.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2022/10/09.
//

import UIKit
import Combine

final class HeadTrackButton: UIButton {
    private let map: HeadTrackableMap
    private var cancellables = Set<AnyCancellable>()
    var headValue: Double = 0 {
        didSet { self.map.changeHead(to: self.headValue) }
    }
    private var isSelectedPublisher: AnyPublisher<Bool, Never> {
        self.publisher(for: \.isSelected).eraseToAnyPublisher()
    }
    
    private func configureButton() {
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 25, weight: .semibold)
        let selectImage = UIImage(systemName: "safari.fill")?.applyingSymbolConfiguration(symbolConfig)
        let deselectImage = UIImage(systemName: "safari")?.applyingSymbolConfiguration(symbolConfig)
        
        self.setImage(deselectImage, for: .normal)
        self.setImage(selectImage, for: .selected)
        self.backgroundColor = .white
        
        self.layer.shadowOffset = .zero
        self.layer.shadowOpacity = 0.3
    }
    
    private func subscribeSelectEvent() {
        self.isSelectedPublisher
            .sink { [weak self] in
                self?.map.switchHeadTracking(isOn: $0)
            }
            .store(in: &self.cancellables)
    }
    
    init(map: HeadTrackableMap) {
        self.map = map
        super.init(frame: .zero)
        self.configureButton()
        self.subscribeSelectEvent()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
