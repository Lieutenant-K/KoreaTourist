//
//  InfoCell.swift
//  KakaoMap
//
//  Created by 김윤수 on 2022/09/16.
//

import UIKit
import SnapKit

final class OverviewInfoCell: BaseInfoCell {
    
    private let arrowImage = UIImageView(systemName: "chevron.down")
    
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
    
    override func configureCell() {
        iconImageView.image = UIImage(systemName: "text.alignleft")
        titleLabel.text = "개요"
    }
    
    override func addSubviews() {
        super.addSubviews()
        contentView.addSubview(contentLabel)
        contentView.addSubview(arrowImage)
        
    }
    
    override func addConstraints() {
        super.addConstraints()
        
        arrowImage.snp.makeConstraints { make in
            make.trailing.top.equalTo(contentView).inset(18)
            make.width.equalTo(iconImageView.snp.height)
            make.height.equalTo(titleLabel)
            
        }
        
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.leading.bottom.trailing.equalTo(contentView).inset(18)
        }
        
    }

}
