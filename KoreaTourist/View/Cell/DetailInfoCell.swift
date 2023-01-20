//
//  DetailInfoCell.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2022/11/04.
//

import UIKit
import Then

final class DetailInfoCell: BaseInfoCell {
    let stackView = UIStackView(frame: .zero)
    
    func inputData(data: DetailInfo){
        removeSubviews()
        
        iconImageView.image = data.iconImage
        titleLabel.text = data.title
        
        data.contentList.forEach {
            if !$0.1.isEmpty {
                let labelStack = LabelStackView(title: $0.0, content: $0.1)

                labelStack.updateAxisUsingContentLines()
                
                stackView.addArrangedSubview(labelStack)
            }
        }
    }
    
    private func removeSubviews() {
        stackView.arrangedSubviews.forEach {
            stackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
    }
    
    override func configureCell() {
        super.configureCell()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 12
    }
    
    override func addSubviews() {
        super.addSubviews()
        contentView.addSubview(stackView)
    }
    
    override func addConstraints() {
        super.addConstraints()
        stackView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.bottom.trailing.equalTo(contentView).inset(12)
        }
    }
}
