//
//  PopupView.swift
//  KakaoMap
//
//  Created by 김윤수 on 2022/09/15.
//

import UIKit
import SnapKit

class PopupView: BaseView {
    
    let announceLabel: BasePaddingLabel = {
        let view = BasePaddingLabel(value: 20)
        view.font = .systemFont(ofSize: 24, weight: .semibold)
        view.textColor = .label
        view.textAlignment = .center
        view.numberOfLines = 1
        view.lineBreakMode = .byWordWrapping
        view.backgroundColor = .tertiarySystemGroupedBackground
        view.clipsToBounds = true
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.label.cgColor
        view.text = "새로운 장소 발견!"
        return view
    }()
    
    let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .tertiarySystemGroupedBackground
//        view.clipsToBounds = true
        view.layer.cornerRadius = 16
        view.layer.shadowOffset = CGSize(width: 0, height: 0)
        view.layer.shadowOpacity = 0.5
        
        return view
    }()
    
    let imageView: UIImageView = {
        let view = UIImageView()
        view.clipsToBounds = true
        view.layer.cornerRadius = 10
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    let titleLabel: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 24, weight: .semibold)
        view.textColor = .label
        view.textAlignment = .center
        view.numberOfLines = 0
        view.lineBreakMode = .byWordWrapping
        view.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        view.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return view
    }()
    
    let descriptLabel: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 18, weight: .medium)
        view.textColor = .secondaryLabel
        view.textAlignment = .center
        view.numberOfLines = 0
        view.lineBreakMode = .byWordWrapping
        return view
    }()
    
    let okButton: UIButton = {
        let view = UIButton(type: .custom)
        view.setTitle("확인", for: .normal)
        view.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        view.setTitleColor(.label, for: .normal)
        return view
    }()
    
    let detailButton: UIButton = {
        let view = UIButton(type: .custom)
        view.setTitle("세부정보 보기", for: .normal)
        view.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        view.setTitleColor(.label, for: .normal)
        return view
    }()
    
    private lazy var buttonStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [okButton, detailButton])
        view.axis = .horizontal
        view.distribution = .fillEqually
        view.alignment = .fill
        return view
    }()
    
    override func setBackground() {
        
        backgroundColor = UIColor.black.withAlphaComponent(0.3)
    }
    
    override func addSubviews() {
        
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptLabel)
        contentView.addSubview(buttonStackView)
        
        addSubview(contentView)
        addSubview(announceLabel)
        
    }
    
    override func addConstraint() {
        
        contentView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(40)
            make.height.equalTo(contentView.snp.width).multipliedBy(1.2)
        }
        
        imageView.snp.makeConstraints { make in
            make.top.equalTo(40)
            make.leading.trailing.equalToSuperview().inset(40)
            make.height.equalTo(imageView.snp.width).multipliedBy(2.0 / 3.0)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.leading.greaterThanOrEqualTo(20)
            make.trailing.lessThanOrEqualTo(-20)
        }
        
        descriptLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.leading.greaterThanOrEqualTo(20)
            make.trailing.lessThanOrEqualTo(-20)
            make.bottom.equalTo(buttonStackView.snp.top).offset(-20)
        }
        
        buttonStackView.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalToSuperview()
            make.height.equalTo(50)
        }
        
        announceLabel.snp.makeConstraints { make in
            make.leading.trailing.equalTo(contentView)
            make.bottom.equalTo(contentView.snp.top).offset(-12)
        }
    }
    
}
