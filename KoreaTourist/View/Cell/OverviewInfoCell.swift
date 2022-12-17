//
//  InfoCell.swift
//  KakaoMap
//
//  Created by 김윤수 on 2022/09/16.
//

import UIKit
import SnapKit

final class OverviewInfoCell: BaseInfoCell, IntroCell, ExpandableCell {
    let arrowImage = UIImageView(systemName: "chevron.down")
    let contentLabel = UILabel()
    let stackView = UIStackView(frame: .zero)
    var isExpand: Bool = false  {
        didSet {
            arrowImage.image = isExpand ? UIImage(systemName: "chevron.up") : UIImage(systemName: "chevron.down")
            contentLabel.numberOfLines = isExpand ? 0 : 2
        }
    }
    
    func inputData(intro: Intro) {
        contentLabel.text = intro.overview
    }
    
    override func configureCell() {
        super.configureCell()
        iconImageView.image = UIImage(systemName: "text.alignleft")
        titleLabel.text = "개요"
        arrowImage.contentMode = .scaleAspectFit
        
        contentLabel.font = .systemFont(ofSize: 18, weight: .regular)
        contentLabel.textAlignment = .left
        contentLabel.textColor = .label
        contentLabel.numberOfLines = 2
        
        stackView.spacing = 8
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.axis = .vertical
        stackView.addArrangedSubview(contentLabel)
        stackView.addArrangedSubview(arrowImage)
    }
    
    override func addSubviews() {
        super.addSubviews()
        contentView.addSubview(stackView)
        
    }
    
    override func addConstraints() {
        super.addConstraints()
        stackView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview().inset(12)
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
        }
    }
}
