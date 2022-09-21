//
//  PopupView.swift
//  KakaoMap
//
//  Created by 김윤수 on 2022/09/15.
//

import UIKit
import SnapKit
import Then

class PopupView: BaseView {
    
    private let announceLabel = BasePaddingLabel(value: 20).then {
        
        $0.font = .systemFont(ofSize: 24, weight: .semibold)
        $0.textColor = .label
        $0.textAlignment = .center
        $0.numberOfLines = 1
        $0.lineBreakMode = .byWordWrapping
//        $0.backgroundColor = .tertiarySystemGroupedBackground
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 16
        $0.layer.borderWidth = 1.5
        $0.layer.borderColor = UIColor.secondaryLabel.cgColor
        $0.text = "새로운 장소 발견!"
        
    }
    
    private lazy var announceView = UIView().then {
        
        let visual = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
        visual.clipsToBounds = true
        visual.layer.cornerRadius = 16
        
        $0.addSubview(visual)
        $0.layer.shadowOffset = CGSize(width: 0, height: 0)
        $0.layer.shadowOpacity = 0.5
        
        visual.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        visual.contentView.addSubview(announceLabel)
        announceLabel.snp.makeConstraints { $0.edges.equalToSuperview() }
        
    }
    
    let contentView = UIView().then {
        
        let visual = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
        visual.clipsToBounds = true
        visual.layer.cornerRadius = 16
        $0.addSubview(visual)
        visual.snp.makeConstraints { $0.edges.equalToSuperview() }
        
//        $0.backgroundColor = .tertiarySystemGroupedBackground
//        view.clipsToBounds = true
        $0.layer.cornerRadius = 16
        $0.layer.shadowOffset = CGSize(width: 0, height: 0)
        $0.layer.shadowOpacity = 0.5
        
        
    }
    
    let imageView = UIImageView().then {
        
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 10
        $0.contentMode = .scaleAspectFill
        
    }
    
    let titleLabel = UILabel().then {
        
        $0.font = .systemFont(ofSize: 24, weight: .semibold)
        $0.textColor = .label
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.lineBreakMode = .byWordWrapping
        $0.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        $0.setContentHuggingPriority(.defaultHigh, for: .vertical)
        
    }
    
    let descriptLabel = UILabel().then {
        
        $0.font = .systemFont(ofSize: 18, weight: .medium)
        $0.textColor = .secondaryLabel
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.lineBreakMode = .byWordWrapping
        
    }
    
    let okButton = UIButton(type: .custom).then {
        
        $0.setTitle("확인", for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        $0.setTitleColor(.label, for: .normal)
        
    }
    
    let detailButton = UIButton(type: .custom).then {
        
        $0.setTitle("세부정보 보기", for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        $0.setTitleColor(.label, for: .normal)
        
        
    }
    
    private lazy var buttonStackView = UIStackView(arrangedSubviews: [okButton, detailButton]).then {
        
        $0.axis = .horizontal
        $0.distribution = .fillEqually
        $0.alignment = .fill
        
    }
    
    override func setBackground() {
        
        backgroundColor = UIColor.black.withAlphaComponent(0.15)
    }
    
    override func addSubviews() {
        
        [imageView, titleLabel, descriptLabel, buttonStackView].forEach { contentView.addSubview($0) }
        
        [contentView, announceView].forEach { addSubview($0) }
        
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
        
        announceView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(contentView)
            make.bottom.equalTo(contentView.snp.top).offset(-12)
            make.height.equalTo(announceLabel.snp.height)
        }
    }
    
}
