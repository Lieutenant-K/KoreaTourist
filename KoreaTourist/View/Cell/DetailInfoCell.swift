//
//  DetailInfoCell.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2022/11/04.
//

import UIKit
import Then

final class DetailInfoCell: BaseInfoCell {
    
    lazy var stackView = UIStackView(arrangedSubviews: []).then {
        $0.axis = .vertical
        $0.distribution = .fill
        $0.spacing = 6
        
    }
    
    func inputData(data: DetailInfo){
        
//        guard let data = data els e { return }
        iconImageView.image = data.iconImage
        titleLabel.text = data.title
        data.contentList.forEach {
            stackView.addArrangedSubview(LabelStackView(title: $0.0, content: $0.1))
        }

    }
    
    /*
    func checkValidation() {
        var isDisplay = false
        [eventView, eventAgeView].forEach { view in
            if view.contentLabel.isValidate {
                view.isHidden = false
                isDisplay = isDisplay || true
            } else {
                view.isHidden = true
                isDisplay = isDisplay || false
            }
        }
        isHidden = !isDisplay
        
    }
    */
    
    override func addSubviews() {
        super.addSubviews()
        contentView.addSubview(stackView)
        
    }
    
    override func addConstraints() {
        super.addConstraints()
        
        stackView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.bottom.trailing.equalTo(contentView).inset(12)
        }
        
    }

}
