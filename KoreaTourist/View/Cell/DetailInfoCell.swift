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
        $0.spacing = 12
        
    }
    
    func inputData(data: DetailInfo){
        
//         계속 cellProvider가 호출됨. 이유가 뭘까?
//        if titleLabel.text == data.title {
//            return
//        }
        
        iconImageView.image = data.iconImage
        titleLabel.text = data.title
        data.contentList.forEach {
            if !$0.1.isEmpty {
                let labelStack = LabelStackView(title: $0.0, content: $0.1)
//                print(labelStack.contentLabel.countLines())
                if labelStack.contentLabel.countLines() > 1 {
                    labelStack.contentLabel.numberOfLines = 0
                    labelStack.axis = .vertical
                }
                stackView.addArrangedSubview(labelStack)
            }
        }

    }
    
    
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
