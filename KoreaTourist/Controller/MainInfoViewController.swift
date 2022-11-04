//
//  MainInfoViewController.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2022/11/02.
//

import UIKit
import NMapsMap

class MainInfoViewController: BaseViewController {
    
    let place: CommonPlaceInfo
    var galleryImages: [PlaceImage] = []
    
    let subInfoVC: SubInfoViewController
    let mainInfoView = MainInfoView()
    
    override func loadView() {
        view = mainInfoView
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addChildVC()
        configureLocationView()
        configureGalleryView()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateMapCameraPos()
    }
    
    private func configureGalleryView() {
        
        
        
    }
    
    private func configureLocationView() {
        
        mainInfoView.locationView.addressLabel.text = "\(place.addr1)\n\(place.addr2)"
        
        mainInfoView.locationView.configureMapView(pos: place.position, date: place.discoverDate)
        
    }
    
    private func updateMapCameraPos() {
        
        let update = NMFCameraUpdate(scrollTo: place.position, zoomTo: 15)
        mainInfoView.locationView.mapView.moveCamera(update)
    }
    
    private func fetchGalleryImages() {
        realm.fetchPlaceImages(contentId: place.contentId) {[weak self] in
            self?.galleryImages = $0
        }
    }
    
    func addChildVC() {
        
        addChild(subInfoVC)
        mainInfoView.subInfoView.addSubview(subInfoVC.view)
        
        subInfoVC.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        subInfoVC.didMove(toParent: self)
        
        
    }
    
    init(place: CommonPlaceInfo){
        self.place = place
        self.subInfoVC = SubInfoViewController(place: place)
        super.init()
    }
    
}
