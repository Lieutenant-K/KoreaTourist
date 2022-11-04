//
//  InfoCell.swift
//  KakaoMap
//
//  Created by 김윤수 on 2022/09/16.
//

import UIKit
import SnapKit

final class OverviewInfoCell: BaseInfoCell, IntroCell, ExpandableCell {
    
    let arrowImage = UIImageView(systemName: "chevron.down").then {
        $0.contentMode = .scaleAspectFit
    }
    
    var isExpand: Bool = false  {
        didSet {
            arrowImage.image = isExpand ? UIImage(systemName: "chevron.up") : UIImage(systemName: "chevron.down")
            contentLabel.numberOfLines = isExpand ? 0 : 2
        }
    }
    
    let contentLabel: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 18, weight: .regular)
        view.textAlignment = .left
        view.textColor = .label
        view.numberOfLines = 2
       return view
    }()
    
    lazy var stackView = UIStackView(arrangedSubviews: [contentLabel, arrowImage]).then {
        $0.spacing = 8
        $0.alignment = .fill
        $0.distribution = .fill
        $0.axis = .vertical
    }
    
    func inputData(intro: Intro) {
        contentLabel.text = intro.overview
    }
    
    override func configureCell() {
        iconImageView.image = UIImage(systemName: "text.alignleft")
        titleLabel.text = "개요"
    }
    
    override func addSubviews() {
        super.addSubviews()
        contentView.addSubview(stackView)
        
    }
    
    override func addConstraints() {
        super.addConstraints()
        
        stackView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview().inset(12)
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
        }
    }
    

}
