//
//  BaseCell.swift
//  KakaoMap
//
//  Created by 김윤수 on 2022/09/16.
//

import UIKit
import SnapKit

class BaseInfoCell: UITableViewCell {
    let iconImageView = UIImageView()
    let titleLabel = UILabel()
    
    func configureCell(){
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textAlignment = .left
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 1
        titleLabel.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        titleLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }
    
    func addSubviews() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(iconImageView)
    }
    
    func addConstraints() {
        iconImageView.snp.makeConstraints { make in
            make.leading.top.equalTo(contentView).inset(12)
            make.width.equalTo(iconImageView.snp.height)
            make.height.equalTo(titleLabel)
            
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(iconImageView)
            make.leading.equalTo(iconImageView.snp.trailing).offset(8)
            make.trailing.lessThanOrEqualTo(contentView).offset(-18)
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureCell()
        addSubviews()
        addConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
}
