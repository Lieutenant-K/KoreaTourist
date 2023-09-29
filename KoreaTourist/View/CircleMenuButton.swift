//
//  CircleMenuButton.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2023/05/20.
//

import UIKit
import Combine

import CircleMenu

final class CircleMenuButton: CircleMenu {
    private var selectedButtonIndex = PassthroughSubject<Int, Never>()
    var isFilterOn = false
    var selectedMenu: AnyPublisher<MapMenu, Never> {
        self.selectedButtonIndex
            .compactMap { MapMenu(rawValue: $0) }
            .eraseToAnyPublisher()
    }
    
    init() {
        super.init(frame: .zero, normalIcon: nil, selectedIcon: nil)
        self.delegate = self
        self.configureButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CircleMenuButton: CircleMenuDelegate {
    func circleMenu(_ circleMenu: CircleMenu, willDisplay button: UIButton, atIndex: Int) {
        let menu = MapMenu(rawValue: atIndex)
        button.setImage(menu?.image, for: .normal)
        button.backgroundColor = .white
        
        if menu == .vision && self.isFilterOn {
            let image = UIImage(systemName: "eye.slash.fill")
            button.setImage(image, for: .normal)
        }
    }
    
    func circleMenu(_ circleMenu: CircleMenu, buttonWillSelected button: UIButton, atIndex: Int) {
        self.selectedButtonIndex.send(atIndex)
    }
    
    func circleMenu(_ circleMenu: CircleMenu, buttonDidSelected button: UIButton, atIndex: Int) {
        self.isSelected = false
    }
}

extension CircleMenuButton {
    private func configureButton() {
        let config = UIImage.SymbolConfiguration(pointSize: 25, weight: .medium)
        let selectedImage = UIImage(systemName: "xmark")?.applyingSymbolConfiguration(config)
        
        self.setImage(.backpack, for: .normal)
        self.setImage(selectedImage, for: .selected)
        self.backgroundColor = .white
        self.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        self.layer.shadowOffset = .zero
        self.layer.shadowOpacity = 0.3
        self.duration = 0.3
        self.distance = 85
        self.startAngle = -90
        self.endAngle = 90
        self.buttonsCount = MapMenu.allCases.count
    }
}
