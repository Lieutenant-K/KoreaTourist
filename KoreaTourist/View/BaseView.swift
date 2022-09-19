//
//  BaseView.swift
//  KakaoMap
//
//  Created by 김윤수 on 2022/09/15.
//

import UIKit

class BaseView: UIView {

    func addConstraint() {}
    
    func addSubviews() {}
    
    func setBackground() {
        backgroundColor = .systemBackground
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        addConstraint()
        setBackground()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
