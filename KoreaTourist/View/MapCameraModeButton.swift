//
//  MapCameraModeButton.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2023/05/20.
//

import UIKit
import Combine

import CombineCocoa

final class MapCameraModeButton: UIButton {
    private let map: DynamicCameraModeMap
    private var cancellables = Set<AnyCancellable>()
    private var currentMode: MapCameraMode = .navigation
    private var previousMode: MapCameraMode? {
        willSet { self.changeButtonState(for: newValue) }
    }
    
    init(map: DynamicCameraModeMap) {
        self.map = map
        super.init(frame: .zero)
        self.configureButton()
        self.subscribeTapEvent()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func switchMode(to mode: MapCameraMode) {
        self.setPreviousMode(with: mode)
        self.currentMode = mode
        self.map.changeCameraMode(to: mode)
    }
}

extension MapCameraModeButton {
    private func configureButton() {
        self.isHidden = true
        self.backgroundColor = .white
        self.layer.shadowOffset = .zero
        self.layer.shadowOpacity = 0.15
    }
    
    private func subscribeTapEvent() {
        self.tapPublisher
            .compactMap { [weak self] _ in
                self?.previousMode
            }
            .sink { [weak self] in
                self?.switchMode(to: $0)
            }
            .store(in: &self.cancellables)
    }
    
    private func setPreviousMode(with mode: MapCameraMode) {
        switch mode {
        case .navigation:
            self.previousMode = .search
        case .search:
            self.previousMode = .navigation
        case .select:
            if case .select = self.currentMode { return }
            else { self.previousMode = self.currentMode }
        }
    }
    
    private func iconImage(for mode: MapCameraMode) -> UIImage? {
        switch mode {
        case .navigation:
            return UIImage(systemName: "location.fill")
        case .search:
            return UIImage(systemName: "map.fill")
        case .select:
            return nil
        }
    }
    
    private func changeButtonState(for mode: MapCameraMode?) {
        if let mode {
            let image = self.iconImage(for: mode)
            self.isHidden = false
            self.setImage(image, for: .normal)
        } else {
            self.isHidden = true
            self.setImage(nil, for: .normal)
        }
    }
}
