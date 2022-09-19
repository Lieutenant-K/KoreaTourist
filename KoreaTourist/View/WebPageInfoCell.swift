//
//  WebPageCell.swift
//  KakaoMap
//
//  Created by 김윤수 on 2022/09/17.
//

import UIKit
import SnapKit

final class WebPageInfoCell: BaseInfoCell {
    
    let contentLabel: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 20, weight: .medium)
        view.textAlignment = .left
        view.textColor = .label
        view.numberOfLines = 1
        view.adjustsFontSizeToFitWidth = true
        
       return view
    }()
    
    func checkValidation() {
        isHidden = contentLabel.isValidate ? false : true
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
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.leading.bottom.trailing.equalTo(contentView).inset(18)
        }
        
    }

}
