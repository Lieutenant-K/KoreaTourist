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
        $0.font = .systemFont(ofSize: 18, weight: .medium)
        $0.numberOfLines = 0
        $0.textAlignment = .center
    }
    
    let mapView = NMFMapView().then {
        $0.isScrollGestureEnabled = false
    }
    
    func configureMapView(pos: NMGLatLng, date: Date?){
        
        let formatter = DateFormatter()
        formatter.dateFormat = """
                    yyyy년 MM월 dd일
                    HH시 mm분
                    발견
                    """
        formatter.locale = Locale(identifier: "ko_KR")
        
        let marker = NMFMarker(position: pos, iconImage: NMF_MARKER_IMAGE_BLACK).then {
            
            $0.captionText = date != nil ? formatter.string(from: date!) : "미발견"
            $0.iconTintColor = .discoverdMarker
            $0.captionColor = .label
            $0.captionHaloColor = .systemBackground
            $0.isHideCollidedSymbols = true
            $0.captionTextSize = 14
            $0.captionOffset = 4
//            $0.height = 50
//            $0.width = 35
        }
        
        marker.mapView = mapView
        
        
    }
    
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
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        
        mapView.adjustInterfaceStyle(style: UITraitCollection.current.userInterfaceStyle)
    }

}
