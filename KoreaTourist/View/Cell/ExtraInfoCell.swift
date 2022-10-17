//
//  ExtraInfoCell.swift
//  KakaoMap
//
//  Created by 김윤수 on 2022/09/19.
//

import UIKit

final class ExtraInfoCell: BaseInfoCell {
    
    let containerView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.distribution = .fill
        view.alignment = .fill
        view.spacing = 14
       return view
    }()
    
    func inputData(data: [ExtraPlaceElement]) {
        
        if containerView.arrangedSubviews.count > 0 {
            return
        }
        
        data.map { (element) -> LabelStackView in
            let label = LabelStackView(title: element.infoTitle, axis: .vertical)
            label.contentLabel.text = element.infoText
            return label
        }.forEach {  containerView.addArrangedSubview($0) }
        
    }
    
    override func configureCell() {
        iconImageView.image = UIImage(systemName: "magnifyingglass.circle.fill")
        titleLabel.text = "살펴보기"
    }
    
    override func addSubviews() {
        super.addSubviews()
        contentView.addSubview(containerView)
        
    }
    
    override func addConstraints() {
        super.addConstraints()
        
        containerView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.leading.bottom.trailing.equalTo(contentView).inset(18)
        }
        
    }
    
}
