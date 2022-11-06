//
//  WebPageCell.swift
//  KakaoMap
//
//  Created by 김윤수 on 2022/09/17.
//

import UIKit
import SnapKit
import Then

final class WebPageInfoCell: BaseInfoCell, IntroCell {
    
    let contentLabel = UITextView().then {
        $0.backgroundColor = .clear
        $0.dataDetectorTypes = .link
        $0.isEditable = false
        $0.isScrollEnabled = false
        $0.font = .systemFont(ofSize: 18, weight: .medium)
        $0.textAlignment = .left
        $0.textColor = .label
    }
    
    func inputData(intro: Intro) {
        contentLabel.text = intro.homepage
    }
    
    override func configureCell() {
        iconImageView.image = UIImage(systemName: "safari.fill")
        titleLabel.text = "웹페이지"
    }
    
    override func addSubviews() {
        super.addSubviews()
        contentView.addSubview(contentLabel)
        
    }
    
    override func addConstraints() {
        super.addConstraints()
        
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.bottom.trailing.equalTo(contentView).inset(12)
        }
        
    }

}
