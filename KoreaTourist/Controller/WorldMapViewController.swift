//
//  WorldMapViewController.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2022/10/11.
//

import UIKit
import RealmSwift
import NMapsMap

final class WorldMapViewController: BaseViewController {
    let worldMapView = WorldMapView()
    var placeList: [PlaceMarker] = []
    var placeId: Int?
    
    init(placeId: Int? = nil) {
        self.placeId = placeId
        super.init()
    }
    
    // MARK: - LifeCycle
    override func loadView() {
        view = worldMapView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchPlace()
        setPlaceMarker()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        moveWorldMapCamera()
    }
    
    override func configureNavigationItem() {
        title = "월드맵"
        navigationItem.largeTitleDisplayMode = .never
        
        let appear = UINavigationBarAppearance()
        appear.configureWithTransparentBackground()
        appear.backgroundEffect = .init(style: .regular)
        
        navigationItem.standardAppearance = appear
        navigationItem.scrollEdgeAppearance = appear
    }
    
    // MARK: User Interface Change
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        placeList.forEach { $0.updateMarkerAppearnce() }
    }

}

// MARK: Helper Function
extension WorldMapViewController {
    private func moveWorldMapCamera() {
        let points = placeList.map { $0.position }
        
        if !points.isEmpty {
            let bounds = NMGLatLngBounds(latLngs: points)
            let update = NMFCameraUpdate(fit: bounds, padding: 20)
            
            update.animation = .easeOut
            update.animationDuration = 0.75
            
            worldMapView.moveCamera(update)
        }
    }
     
    private func fetchPlace() {
        var places: [CommonPlaceInfo] = []
        if let id = placeId, let place = realm.loadPlaceInfo(infoType: CommonPlaceInfo.self, contentId: id) {
            places = [place]
        } else {
            places = realm.fetchPlaces(type: CommonPlaceInfo.self)
                .where { $0.discoverDate != nil }
                .map{ $0 }
        }
        placeList = places.map{ PlaceMarker(place: $0) }
    }
    
    private func setPlaceMarker() {
        let handler: NMFOverlayTouchHandler = {
            [weak self] in
            if let marker = $0 as? PlaceMarker {
                let sub = SubInfoViewController(place: marker.placeInfo)
                let main = MainInfoViewController(place: marker.placeInfo, subInfoVC: sub)
                let vc = PlaceInfoViewController(place: marker.placeInfo, mainInfoVC: main)
                let navi = UINavigationController(rootViewController: vc)
                navi.modalPresentationStyle = .fullScreen
                self?.present(navi, animated: true)
            }
            return true
        }
        
        placeList.forEach {
            $0.mapView = worldMapView
            $0.captionMinZoom = 12
            $0.touchHandler = placeId == nil ? handler : nil
        }
    }
}
