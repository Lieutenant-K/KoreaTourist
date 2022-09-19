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
    
    let titleLabel: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 22, weight: .semibold)
        view.textAlignment = .left
        view.textColor = .label
        view.numberOfLines = 1
        view.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        view.setContentHuggingPriority(.defaultHigh, for: .vertical)
       return view
    }()
    
    func configureCell(){}
    
    func addSubviews() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(iconImageView)
    }
    
    func addConstraints() {
        
        iconImageView.snp.makeConstraints { make in
            make.leading.top.equalTo(contentView).inset(18)
            make.width.equalTo(iconImageView.snp.height)
            make.height.equalTo(titleLabel)
            
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(iconImageView)
            make.leading.equalTo(iconImageView.snp.trailing).offset(12)
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

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }

}
