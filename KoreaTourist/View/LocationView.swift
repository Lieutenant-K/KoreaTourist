//
//  LocationView.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2022/11/02.
//

import UIKit
import NMapsMap

final class LocationView: BaseView {
    let addressLabel = UILabel()
    let mapView = NMFMapView()
    var marker: NMFMarker?
    
    init() {
        super.init(frame: .zero)
        configureSubviews()
    }
    
    func createMarker(pos: NMGLatLng, date: Date?){
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat =  """
                                yyyy년 MM월 dd일
                                HH시 mm분
                                발견
                                """
        
        marker = NMFMarker(position: pos, iconImage: NMF_MARKER_IMAGE_BLACK).then {
            
            $0.captionText = date != nil ? formatter.string(from: date!) : "미발견"
            $0.iconTintColor = .discoverdMarker
            $0.captionColor = .label
            $0.captionHaloColor = .systemBackground
            $0.isHideCollidedSymbols = true
            $0.captionTextSize = 14
            $0.captionOffset = 4
            $0.mapView = mapView
        }
    }
    
    private func configureSubviews() {
        addressLabel.font = .systemFont(ofSize: 18, weight: .medium)
        addressLabel.numberOfLines = 0
        addressLabel.textAlignment = .center
        
        mapView.adjustInterfaceStyle(style: UITraitCollection.current.userInterfaceStyle)
        mapView.mapType = .navi
        mapView.gestureRecognizers?.forEach {
            mapView.removeGestureRecognizer($0)
        }
    }
    
    override func addSubviews() {
        [addressLabel, mapView].forEach { addSubview($0) }
    }
    
    override func addConstraint() {
        addressLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(12)
        }
        
        mapView.snp.makeConstraints {
            $0.top.equalTo(addressLabel.snp.bottom).offset(14)
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(150)
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        marker?.iconTintColor = .discoverdMarker
        marker?.captionColor = .label
        marker?.captionHaloColor = .systemBackground
        
        mapView.adjustInterfaceStyle(style: UITraitCollection.current.userInterfaceStyle)
    }
}
