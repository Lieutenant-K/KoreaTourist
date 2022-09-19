//
//  AddressCell.swift
//  KakaoMap
//
//  Created by 김윤수 on 2022/09/17.
//

import UIKit
import SnapKit

final class AddressInfoCell: BaseInfoCell {
    
    let contentLabel: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 20, weight: .medium)
        view.textAlignment = .left
        view.textColor = .label
        view.numberOfLines = 1
        view.adjustsFontSizeToFitWidth = true
       return view
    }()
    
    override func configureCell() {
        iconImageView.image = UIImage(systemName: "signpost.right.fill")
        titleLabel.text = "주소"
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
