//
//  MapCameraModeButton.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2023/05/20.
//

import UIKit

final class MapCameraModeButton: UIButton {
    private func configure() {
        self.setImage(UIImage(systemName: "location.fill"), for: .normal)
        self.isHidden = true
        self.backgroundColor = .white
        self.layer.shadowOffset = .zero
        self.layer.shadowOpacity = 0.3
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
