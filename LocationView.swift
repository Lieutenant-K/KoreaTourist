//
//  LocationView.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2022/11/02.
//

import UIKit
import Then
import NMapsMap

class LocationView: BaseView {

    let addressLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16, weight: .medium)
        $0.numberOfLines = 0
        $0.textAlignment = .center
        $0.text = "서울시 동작구 대방동 27길 27\n(06945)"
    }
    
    let mapView = NMFMapView()
    
    override func addSubviews() {
        [addressLabel, mapView].forEach {
            addSubview($0)
        }
    }
    
    override func addConstraint() {
        addressLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(12)
        }
        
        mapView.snp.makeConstraints { make in
            make.top.equalTo(addressLabel.snp.bottom).offset(14)
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(150)
        }
        
//        self.snp.makeConstraints { make in
//            make.height.greaterThanOrEqualTo(0)
//        }
    }

}
