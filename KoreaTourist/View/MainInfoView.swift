//
//  CommonInfoView.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2022/11/01.
//

import UIKit
import SnapKit

class MainInfoView: BaseView {
    let nameLabel = UILabel()
    let locationView = LocationView()
    let galleryView = GalleryView()
    let subInfoView = UIView()
    private lazy var stackView = UIStackView(arrangedSubviews: [locationView, galleryView, subInfoView])
    
    init() {
        super.init(frame: .zero)
        configureSubviews()
    }
    
    private func configureSubviews() {
        nameLabel.font = .systemFont(ofSize: 30, weight: .bold)
        nameLabel.numberOfLines = 0
        nameLabel.textAlignment = .center
        
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .fill
        stackView.distribution = .fill
        
        galleryView.isHidden = true
    }
    
    override func addSubviews() {
        [nameLabel, stackView].forEach { addSubview($0) }
    }
    
    override func addConstraint() {
        nameLabel.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(20)
            $0.centerX.equalToSuperview()
            $0.leading.greaterThanOrEqualToSuperview().offset(12)
            $0.trailing.lessThanOrEqualToSuperview().offset(-12)
        }
        
        stackView.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(20)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
}
