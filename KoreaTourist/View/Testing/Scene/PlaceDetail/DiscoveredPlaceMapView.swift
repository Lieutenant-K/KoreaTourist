//
//  DiscoveredPlaceMapView.swift
//  KoreaTourist
//
//  Created by 김윤수 on 11/12/23.
//

import UIKit
import Combine

import NMapsMap
import Then
import CombineCocoa

final class DiscoveredPlaceMapView: UIView {
    private let addressLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 18, weight: .medium)
        $0.numberOfLines = 0
        $0.textAlignment = .center
    }
    private let mapView = NMFMapView().then {
        $0.adjustInterfaceStyle(style: UITraitCollection.current.userInterfaceStyle)
        $0.mapType = .navi
    }
    private lazy var gestureRecognizer = UITapGestureRecognizer().then {
        self.addGestureRecognizer($0)
    }
    private var marker: NMFMarker?
    
    var tapPublisher: AnyPublisher<Void, Never>  {
        self.gestureRecognizer.tapPublisher
            .map { _ in () }
            .eraseToAnyPublisher()
    }
    
    init() {
        super.init(frame: .zero)
        self.configureSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateAddress(with: String) {
        self.addressLabel.text = with
    }
    
    func displayMarker(position: Coordinate, date: Date?) {
        self.createMarker(pos: position.mapCoordinate, date: date)
        self.updateMapCameraPos(to: position)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        self.marker?.iconTintColor = .discoverdMarker
        self.marker?.captionColor = .label
        self.marker?.captionHaloColor = .systemBackground
        
        self.mapView.adjustInterfaceStyle(style: UITraitCollection.current.userInterfaceStyle)
    }
}

extension DiscoveredPlaceMapView {
    private func createMarker(pos: NMGLatLng, date: Date?) {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat =  """
                                yyyy년 MM월 dd일
                                HH시 mm분
                                발견
                                """
        
        self.marker = NMFMarker(position: pos, iconImage: NMF_MARKER_IMAGE_BLACK).then {
            $0.captionText = date != nil ? formatter.string(from: date!) : "미발견"
            $0.iconTintColor = .discoverdMarker
            $0.captionColor = .label
            $0.captionHaloColor = .systemBackground
            $0.isHideCollidedSymbols = true
            $0.captionTextSize = 14
            $0.captionOffset = 4
            $0.mapView = self.mapView
        }
    }
    
    private func updateMapCameraPos(to position: Coordinate) {
        let update = NMFCameraUpdate(scrollTo: position.mapCoordinate, zoomTo: 15)
        self.mapView.moveCamera(update)
    }
}

extension DiscoveredPlaceMapView {
    private func configureSubviews() {
        self.addSubview(self.addressLabel)
        self.addressLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(12)
        }
        
        self.addSubview(self.mapView)
        self.mapView.snp.makeConstraints {
            $0.top.equalTo(addressLabel.snp.bottom).offset(14)
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(150)
        }
        
        self.mapView.gestureRecognizers?.forEach {
            self.mapView.removeGestureRecognizer($0)
        }
    }
}
