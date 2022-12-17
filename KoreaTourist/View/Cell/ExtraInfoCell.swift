//
//  ExtraInfoCell.swift
//  KakaoMap
//
//  Created by 김윤수 on 2022/09/19.
//

import UIKit
import Then

final class ExtraInfoCell: BaseInfoCell {
    let stackView = UIStackView(frame: .zero)
    
    func inputData(data: [ExtraPlaceElement]) {
        removeSubviews()
        
        data.forEach {
            let title = $0.infoTitle
            let content = $0.infoText
            let labelStack = LabelStackView(title: title, content: content)
            
            if labelStack.contentLabel.countLines() > 1 {
                labelStack.axis = .vertical
                labelStack.alignment = .fill
            }
            
            stackView.addArrangedSubview(labelStack)
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
        iconImageView.image = UIImage(systemName: "magnifyingglass.circle.fill")
        titleLabel.text = "살펴보기"
        
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
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
