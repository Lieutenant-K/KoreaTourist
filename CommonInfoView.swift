//
//  CommonInfoView.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2022/11/01.
//

import UIKit
import Then
import NMapsMap

class CommonInfoView: BaseView {

    let nameLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 30, weight: .bold)
        $0.text = "대방홈타운 아파트"
        $0.numberOfLines = 0
        $0.textAlignment = .center
    }
    let locationView = LocationView()
    let galleryView = GalleryView()
    let placeInfoTypeView = PlaceInfoTypeView()
    
    private lazy var stackView = UIStackView(arrangedSubviews: [locationView, galleryView, placeInfoTypeView]).then {
        $0.axis = .vertical
        $0.spacing = 20
        $0.alignment = .fill
        $0.distribution = .fill
    }
    
    override func addSubviews() {
        
        [nameLabel, stackView].forEach {
            addSubview($0)
        }
        
    }
    
    override func addConstraint() {
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(20)
            make.centerX.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview().offset(12)
            make.trailing.lessThanOrEqualToSuperview().offset(-12)
        }
        
        stackView.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(20)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        self.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(0)
        }
    }
    
}
