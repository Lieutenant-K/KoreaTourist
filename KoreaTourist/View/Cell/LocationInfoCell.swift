//
//  MapCell.swift
//  KakaoMap
//
//  Created by 김윤수 on 2022/09/17.
//

import UIKit
import SnapKit
import NMapsMap

final class LocationInfoCell: BaseInfoCell {
    
    private var marker: NMFMarker?
    
    let mapView: NMFMapView = {
        let view = NMFMapView()
        view.adjustInterfaceStyle(style: UITraitCollection.current.userInterfaceStyle)
        view.mapType = .navi
        view.isScrollGestureEnabled = false
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        return view
    }()
    
    func marking(pos: NMGLatLng, date: Date?) {
        marker = NMFMarker(position: pos, iconImage: NMF_MARKER_IMAGE_BLACK)
        let position = NMFCameraPosition(pos, zoom: 15)
        
        mapView.moveCamera(NMFCameraUpdate(position: position))
        marker?.iconTintColor = .discoverdMarker
        marker?.captionColor = .label
        marker?.captionHaloColor = .systemBackground
        marker?.isHideCollidedSymbols = true
        marker?.captionTextSize = 14
        marker?.captionOffset = 4
        marker?.mapView = mapView
        
        let formatter = DateFormatter()
        formatter.dateFormat = """
                    yyyy년 MM월 dd일
                    HH시 mm분
                    발견
                    """
        formatter.locale = Locale(identifier: "ko_KR")
        marker?.captionText = date != nil ? formatter.string(from: date!) : "미발견"
    }
    
    override func configureCell() {
        iconImageView.image = UIImage(systemName: "map.fill")
        titleLabel.text = "위치"
    }
    
    override func addSubviews() {
        super.addSubviews()
        contentView.addSubview(mapView)
        
    }
    
    override func addConstraints() {
        super.addConstraints()
        
        mapView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(14)
            make.leading.bottom.trailing.equalTo(contentView).inset(18)
            make.height.equalTo(mapView.snp.width).multipliedBy(0.7)
        }
        
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        let style = UITraitCollection.current.userInterfaceStyle
        mapView.adjustInterfaceStyle(style: style)
        marker?.iconTintColor = .discoverdMarker
        marker?.captionColor = .label
        marker?.captionHaloColor = .systemBackground
    }

}

