//
//  MapActivityIndicator.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2023/06/07.
//

import JGProgressHUD

final class MapActivityIndicator: JGProgressHUD {
    private func configure() {
        self.position = .center
        self.animation = JGProgressHUDFadeAnimation()
        self.indicatorView = JGProgressHUDIndeterminateIndicatorView()
        self.textLabel.text = "장소를 찾는 중..."
        self.interactionType = .blockAllTouches
    }
    
    override init(style: JGProgressHUDStyle) {
        super.init(style: style)
        self.configure()
    }
    
    init() {
        super.init(automaticStyle: ())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
