//
//  MainInfoViewController.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2022/11/02.
//

import UIKit
import NMapsMap
import Kingfisher

class MainInfoViewController: BaseViewController {
    
    let place: CommonPlaceInfo
    var galleryImages: [PlaceImage] = []
    var dataSource: UICollectionViewDiffableDataSource<Int, PlaceImage>!
    
    let subInfoVC: SubInfoViewController
    let mainInfoView = MainInfoView()
    
    override func loadView() {
        view = mainInfoView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addChildVC()
        configureMainInfoView()
        fetchGalleryImages()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateMapCameraPos()
    }
    
    func configureMainInfoView() {
        mainInfoView.nameLabel.text = place.title
        configureLocationView()
        configureGalleryView()
        
    }
    
    
    private func configureLocationView() {
        
        mainInfoView.locationView.addressLabel.text = "\(place.addr1)\n\(place.addr2)"
        
        mainInfoView.locationView.configureMapView(pos: place.position, date: place.discoverDate)
        
    }
    
    private func updateMapCameraPos() {
        
        let update = NMFCameraUpdate(scrollTo: place.position, zoomTo: 15)
        mainInfoView.locationView.mapView.moveCamera(update)
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

extension MainInfoViewController: UICollectionViewDelegate {
    
    private func configureGalleryView() {
        mainInfoView.galleryView.collectionView.delegate = self
        mainInfoView.galleryView.isHidden = true
        
        let cellRegistration = UICollectionView.CellRegistration<DetailImageCell, PlaceImage> { cell, indexPath, itemIdentifier in
            
            let url = URL(string: itemIdentifier.originalImage)
            
            cell.imageView.kf.indicatorType = .activity
            cell.imageView.kf.setImage(with: url ,options: [.transition(.fade(0.5))])
            
        }
        
        dataSource = UICollectionViewDiffableDataSource(collectionView: mainInfoView.galleryView.collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            
            let cell = collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
            
            return cell
            
        })
        
    }
    
    private func updateSnapshot() {
        
        var snapshot = NSDiffableDataSourceSnapshot<Int, PlaceImage>()
        snapshot.appendSections([0])
        snapshot.appendItems(galleryImages)
        
        dataSource.apply(snapshot)
        
    }
    
    
    private func fetchGalleryImages() {
        realm.fetchPlaceImages(contentId: place.contentId) {[weak self] in
            self?.galleryImages = $0
            self?.mainInfoView.galleryView.isHidden = false
            self?.updateSnapshot()
        }
    }
    
}
