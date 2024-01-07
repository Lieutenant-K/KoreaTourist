//
//  TopFloatingView.swift
//  KoreaTourist
//
//  Created by 의식주컴퍼니 on 11/18/23.
//

import UIKit

import SnapKit

final class TopFloatingView: UIView {
    private let titleBar = UINavigationBar()
    private let itemBar = UINavigationBar()
    private let backgroundVisualEffectView: UIVisualEffectView
    var barHeight: CGFloat { 44 }
    
    var titleView: UIView? {
        get { self.titleBar.topItem?.titleView }
        set { 
            let item = UINavigationItem()
            item.titleView = newValue
            self.titleBar.setItems([item], animated: true)
        }
    }
    
    var leftBarItem: UIBarButtonItem? {
        get { self.itemBar.topItem?.leftBarButtonItem }
        set {
            let item = UINavigationItem()
            item.setLeftBarButton(newValue, animated: true)
            self.itemBar.setItems([item], animated: true)
        }
    }
    
    var backgroundAlpha: CGFloat {
        get { self.backgroundVisualEffectView.alpha }
        set { self.backgroundVisualEffectView.alpha = newValue }
    }
    
    init(superView: UIView, backgroundBlur: UIBlurEffect.Style = .regular) {
        let blur = UIBlurEffect(style: backgroundBlur)
        self.backgroundVisualEffectView = UIVisualEffectView(effect: blur)
        super.init(frame: .zero)
        self.configure()
        self.configureSubviews()
        self.attachToSuperview(superView: superView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TopFloatingView {
    private func attachToSuperview(superView: UIView) {
        superView.addSubview(self)
        self.snp.makeConstraints {
            $0.leading.trailing.top.equalToSuperview()
            $0.bottom.equalTo(superView.safeAreaLayoutGuide.snp.top)//.offset(self.barHeight)
        }
    }
    
    private func configureSubviews() {
        self.addSubview(self.backgroundVisualEffectView)
        self.backgroundVisualEffectView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        self.backgroundVisualEffectView.contentView.addSubview(self.titleBar)
        self.titleBar.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(self.barHeight)
        }
        
        self.addSubview(self.itemBar)
        self.itemBar.snp.makeConstraints {
            $0.leading.trailing.bottom.equalTo(self.backgroundVisualEffectView)
            $0.height.equalTo(self.barHeight)
        }
    }
    
    private func configure() {
        let titleBarAppear = UINavigationBarAppearance()
        titleBarAppear.configureWithTransparentBackground()
        titleBarAppear.shadowColor = .separator
        
        let itemBarAppear = UINavigationBarAppearance()
        itemBarAppear.configureWithTransparentBackground()
        
        self.backgroundColor = .clear
        self.titleBar.backgroundColor = .clear
        self.titleBar.standardAppearance = titleBarAppear
        self.titleBar.scrollEdgeAppearance = titleBarAppear
        self.itemBar.backgroundColor = .clear
        self.itemBar.standardAppearance = itemBarAppear
        self.itemBar.scrollEdgeAppearance = itemBarAppear
    }
}
