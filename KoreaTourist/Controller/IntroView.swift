//
//  IntroView.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2022/11/02.
//

import UIKit
import Then

class IntroView: BaseView {

    let titleLabel = UILabel().then {
        $0.text = "개요"
        $0.numberOfLines = 1
        $0.font = .systemFont(ofSize: 24, weight: .semibold)
    }
    
    let overviewLabel = UILabel().then {
        $0.text = "Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda. Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda."
        $0.numberOfLines = 0
        $0.font = .systemFont(ofSize: 18, weight: .medium)
    }
    
    let webpageView = UITextView().then {
        $0.isScrollEnabled = false
        $0.text = "http://naver.com"
        $0.isEditable = false
        $0.font = .systemFont(ofSize: 18, weight: .medium)
    }
    
    lazy var verticalStack = UIStackView(arrangedSubviews: [titleLabel, overviewLabel, webpageView]).then {
        $0.alignment = .fill
        $0.spacing = 8
        $0.axis = .vertical
    }
    
    override func addSubviews() {
        addSubview(verticalStack)
    }
    
    override func addConstraint() {
        verticalStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(20)
        }
        
        self.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(0)
        }
    }

}
