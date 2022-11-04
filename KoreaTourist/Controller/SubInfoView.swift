//
//  PlaceInfoTypeView.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2022/11/02.
//

import UIKit
import Then

class SubInfoView: BaseView {
    
    var buttons = [UIButton]()
    
    let contentView = UIView()
    
    lazy var buttonStack = UIStackView(arrangedSubviews: []).then {
        $0.alignment = .fill
        $0.distribution = .fillEqually
        $0.axis = .horizontal
        $0.spacing = 2
    }
    
    
    private func configureButtons() {
        
        let titles = ["소개", "정보", "안내"]
        
        for i in 0..<titles.count {
            let button = UIButton(type: .system)
            button.titleLabel?.font = .systemFont(ofSize: 20, weight: .medium)
            button.setTitle(titles[i], for: .normal)
            button.setTitleColor(.label, for: .normal)
            button.tag = i
            buttons.append(button)
            buttonStack.addArrangedSubview(button)
        }
        
    }

    override func addSubviews() {
        addSubview(buttonStack)
        addSubview(contentView)
    }

    override func addConstraint() {
        
        buttonStack.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview()
            make.height.equalTo(60)
        }
        
        contentView.snp.makeConstraints { make in
            make.top.equalTo(buttonStack.snp.bottom)
            make.leading.bottom.trailing.equalToSuperview()
            make.height.equalTo(1000)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureButtons()
    }
    
}
