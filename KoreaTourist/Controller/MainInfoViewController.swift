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
    var galleryImages: [PlaceImage] = [] {
        didSet {
            updateSnapshot()
            updateScrollPos()
            activateAutoScrollTimer()
        }
    }
    
//    var currentPageIndex = 0
    var dataSource: UICollectionViewDiffableDataSource<Int, Int>!
    var autoScrollTimer = Timer()
    
    let subInfoVC: SubInfoViewController
    let mainInfoView = MainInfoView()
    
    override func loadView() {
        view = mainInfoView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        realm.printRealmFileURL()
        addObserver()
        addChildVC()
        configureMainInfoView()
        fetchGalleryImages()
//        activateAutoScrollTimer()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateMapCameraPos()
        updateScrollPos()
    }
    
    /*
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print(#function)
        updateMapCameraPos()
        updateScrollPos()

    }
    */
    
    private func configureMainInfoView() {
        mainInfoView.nameLabel.text = place.title
        configureLocationView()
        configureGalleryView()
        
    }
    
    private func addObserver() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(deviceOrientationChanged(_:)), name: UIDevice.orientationDidChangeNotification, object: nil)
        
    }
    
    @objc func deviceOrientationChanged(_ noti: Notification) {
        
        updateScrollPos()
        
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
    
    var originCount: Int { galleryImages.count / 3 }
    
    private func configureGalleryView() {
        
        mainInfoView.galleryView.collectionView.delegate = self
        
        let cellRegistration = UICollectionView.CellRegistration<DetailImageCell, PlaceImage> { cell, indexPath, itemIdentifier in
            
            let url = URL(string: itemIdentifier.originalImage)
            
            cell.imageView.kf.indicatorType = .activity
            cell.imageView.kf.setImage(with: url ,options: [.transition(.fade(0.5))])
            
        }
        
        dataSource = UICollectionViewDiffableDataSource(collectionView: mainInfoView.galleryView.collectionView, cellProvider: { [unowned self] collectionView, indexPath, itemIdentifier in
            
            let cell = collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: galleryImages[itemIdentifier])
            
            return cell
            
        })
        
    }
    
    
    func activateAutoScrollTimer() {
        
        if originCount < 2 { return }
        
        autoScrollTimer = Timer.scheduledTimer(withTimeInterval: 2.5, repeats: true) { [weak self] _ in
            
            guard let weakSelf = self else { return }
            
            let collectionView = weakSelf.mainInfoView.galleryView.collectionView
            
            let originCount = weakSelf.originCount
            
            guard let cell = collectionView.visibleCells.first, var index = collectionView.indexPath(for: cell)?.row else { return }
            
            
            if index == originCount*2-1  {
                index = originCount-1
                collectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: .centeredHorizontally, animated: false)
                
            }
            
            collectionView.scrollToItem(at: IndexPath(row: index+1, section: 0), at: .centeredHorizontally, animated: true)
            
        }
        
        RunLoop.main.add(autoScrollTimer, forMode: .common)
    }
    
    /*
    func createLayout() -> UICollectionViewLayout {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.scrollDirection = .horizontal
        
        let layout = UICollectionViewCompositionalLayout(section: section, configuration: config)
        
        return layout
        
    }
    */
    /*
    private func updateGalleryPage() {
        
        mainInfoView.galleryView.pageLabel.text = "\(currentPageIndex+1) / \(galleryImages.count)"
        
    }
    */
    
    private func updateScrollPos() {
        
        if let index = dataSource.indexPath(for: originCount) {
            mainInfoView.galleryView.collectionView.scrollToItem(at: index, at: .centeredHorizontally, animated: false)
            mainInfoView.galleryView.pageLabel.text = "1 / \(originCount)"
        }
        
    }
    
    private func updateSnapshot() {
        
        let count = galleryImages.count
        
        var snapshot = NSDiffableDataSourceSnapshot<Int, Int>()
        snapshot.appendSections([0])
        snapshot.appendItems([Int].init(0..<count))
        
        dataSource.apply(snapshot)
        
        
    }
    
    
    private func fetchGalleryImages() {
        realm.fetchPlaceImages(contentId: place.contentId) {[weak self] in
            self?.galleryImages = $0 + $0 + $0
            self?.mainInfoView.galleryView.isHidden = $0.count > 0 ? false : true
//            self?.updateGalleryPage()

        }
    }
    
    /*
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        currentPageIndex = Int(targetContentOffset.pointee.x / scrollView.frame.width)
        
         updateGalleryPage()
        
    }
    */
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
//        print(#function)
        autoScrollTimer.invalidate()
    }

    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let collectionView = mainInfoView.galleryView.collectionView
        
        let originCount = galleryImages.count / 3
        
        guard let cell = collectionView.visibleCells.first, var index = collectionView.indexPath(for: cell)?.row else { return }
        
        if index == originCount * 2 {
            index = originCount
        } else if index == originCount - 1 {
            index = 2*originCount - 1
        }
        
        
        collectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: .centeredHorizontally, animated: false)
        
        if !autoScrollTimer.isValid {
            activateAutoScrollTimer()
        }
//        print(#function)
    }

}
