//
//  DiscoveredMapViewController.swift
//  KoreaTourist
//
//  Created by 의식주컴퍼니 on 11/18/23.
//

import UIKit
import Combine

import Then
import NMapsMap
import SnapKit
import Hero

final class DiscoveredPlaceMapViewController: UIViewController {
    private let mapView = NMFMapView().then {
        $0.logoAlign = .leftBottom
        $0.maxZoomLevel = 18
        $0.minZoomLevel = 8
        $0.mapType = .navi
        $0.setLayerGroup(NMF_LAYER_GROUP_BUILDING, isEnabled: false)
        $0.adjustInterfaceStyle(style: UITraitCollection.current.userInterfaceStyle)
        $0.heroID = "mapView"
    }
    private let closeButton = UIButton(type: .system).then {
        let config = UIImage.SymbolConfiguration(weight: .semibold)
        let image = UIImage(systemName: "xmark")?.withConfiguration(config)
        $0.setImage(image, for: .normal)
        $0.tintColor = .label
    }
    
    private let placeInfo: CommonPlaceInfo
    private var cancellables = Set<AnyCancellable>()
    
    init(placeInfo: CommonPlaceInfo) {
        self.placeInfo = placeInfo
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureSubviews()
        self.binding()
    }
    
    private func binding() {
        self.viewDidAppearPublisher
            .withUnretained(self)
            .sink { object, _ in
                object.displayMarker()
                object.moveMapCamera()
            }
            .store(in: &self.cancellables)
        
        self.closeButton.tapPublisher
            .withUnretained(self)
            .sink { object, _ in
                object.dismiss(animated: true)
            }
            .store(in: &self.cancellables)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        let style = UITraitCollection.current.userInterfaceStyle
        self.mapView.adjustInterfaceStyle(style: style)
    }
}

extension DiscoveredPlaceMapViewController {
    private func displayMarker() {
        let marker = PlaceMarker(place: self.placeInfo)
        marker.mapView = self.mapView
        marker.captionMinZoom = 12
        marker.captionTextSize = 18
//        marker.touchHandler = placeId == nil ? handler : nil
    }
    
    private func moveMapCamera() {
        let update = NMFCameraUpdate(scrollTo: self.placeInfo.position)
        update.animation = .easeOut
        update.animationDuration = 0.2
        self.mapView.moveCamera(update)
    }
    
    private func configureSubviews() {
        self.view.addSubview(self.mapView)
        self.mapView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        self.view.addSubview(self.closeButton)
        self.closeButton.snp.makeConstraints {
            $0.leading.top.equalTo(self.view.safeAreaLayoutGuide).inset(12)
        }
    }
}
