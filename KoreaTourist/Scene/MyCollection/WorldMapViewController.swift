//
//  WorldMapViewController.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2022/10/11.
//

import UIKit

import SnapKit
import NMapsMap

final class WorldMapViewController: UIViewController {
    private let worldMapView = WorldMapView()
    private let repository: CommonUserRepository
    private lazy var placeList: [CommonPlaceInfo] = []
    
    init(repository: CommonUserRepository) {
        self.repository = repository
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LifeCycle
    override func loadView() {
        self.view = self.worldMapView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureNavigationItem()
        self.setPlaceMarker()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.moveMapCamera()
    }
    
    private func configureSubviews() {
        self.view.addSubview(self.worldMapView)
        self.worldMapView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func configureNavigationItem() {
        let appear = UINavigationBarAppearance()
        appear.configureWithDefaultBackground()
        appear.backgroundColor = .clear
        appear.backgroundEffect = .init(style: .regular)
        
        self.title = "월드맵"
        self.navigationItem.largeTitleDisplayMode = .never
        self.navigationItem.standardAppearance = appear
        self.navigationItem.scrollEdgeAppearance = appear
    }
}

// MARK: Helper Function
extension WorldMapViewController {
    private func setPlaceMarker() {
        let placeList = self.repository.load(type: CommonPlaceInfo.self).filter { $0.isDiscovered }
        
        placeList.map { PlaceMarker(place: $0) }
            .forEach { marker in
                marker.captionMinZoom = 12
                marker.mapView = self.worldMapView
            }
        
        self.placeList = placeList
    }
    
    private func moveMapCamera() {
        let points = self.placeList.map { $0.position }
        
        if !points.isEmpty {
            let bounds = NMGLatLngBounds(latLngs: points)
            let update = NMFCameraUpdate(fit: bounds, padding: 60)
            update.animation = .easeOut
            update.animationDuration = 0.75
            self.worldMapView.moveCamera(update)
        }
    }
}
