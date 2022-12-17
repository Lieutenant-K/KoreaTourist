//
//  WebPageCell.swift
//  KakaoMap
//
//  Created by 김윤수 on 2022/09/17.
//

import UIKit
import SnapKit

final class WebPageInfoCell: BaseInfoCell, IntroCell {
    let contentLabel = UITextView()
    
    func inputData(intro: Intro) {
        contentLabel.text = intro.homepage
    }
    
    override func configureCell() {
        super.configureCell()
        iconImageView.image = UIImage(systemName: "safari.fill")
        titleLabel.text = "웹페이지"
        
        contentLabel.backgroundColor = .clear
        contentLabel.dataDetectorTypes = .link
        contentLabel.isEditable = false
        contentLabel.isScrollEnabled = false
        contentLabel.font = .systemFont(ofSize: 18, weight: .medium)
        contentLabel.textAlignment = .left
        contentLabel.textColor = .label
    }
    
    override func addSubviews() {
        super.addSubviews()
        contentView.addSubview(contentLabel)
        
    }
    
    override func addConstraints() {
        super.addConstraints()
        
        contentLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.bottom.trailing.equalTo(contentView).inset(12)
        }
        
    }
}
