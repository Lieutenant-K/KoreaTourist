//
//  PlaceInfoTypeView.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2022/11/02.
//

import UIKit
import Then

class PlaceInfoTypeView: BaseView {
    
    let introButton = UIButton().then {
        $0.titleLabel?.font = .systemFont(ofSize: 20, weight: .medium)
        $0.setTitle("소개", for: .normal)
        $0.setTitleColor(.label, for: .normal)
    }
    
    let detailButton = UIButton().then {
        $0.titleLabel?.font = .systemFont(ofSize: 20, weight: .medium)
        $0.setTitle("디테일", for: .normal)
        $0.setTitleColor(.label, for: .normal)
    }
    
    let extraButton = UIButton().then {
        $0.titleLabel?.font = .systemFont(ofSize: 20, weight: .medium)
        $0.setTitle("추가", for: .normal)
        $0.setTitleColor(.label, for: .normal)
    }
    
    let contentView = UIView()
    
    lazy var buttonStack = UIStackView(arrangedSubviews: [introButton, detailButton, extraButton]).then {
        $0.alignment = .fill
        $0.distribution = .fillEqually
        $0.axis = .horizontal
        $0.spacing = 2
    }
    
    lazy var verticalStack = UIStackView(arrangedSubviews: [buttonStack, contentView]).then {
        $0.alignment = .fill
        $0.distribution = .fill
        $0.axis = .vertical
    }

    override func addSubviews() {
        addSubview(verticalStack)
    }
    
    override func addConstraint() {
        
        verticalStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(0)
//            make.height.equalTo(0)
        }
        
        self.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(0)
        }
    }
    
}
