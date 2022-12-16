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
    let subInfoVC: SubInfoViewController
    var dataSource: UICollectionViewDiffableDataSource<Int, Int>!
    let mainInfoView = MainInfoView()
    var autoScrollTimer = Timer()
    var galleryImages: [PlaceImage] = [] {
        didSet {
            updateSnapshot()
            resetScrollPos()
            activateAutoScrollTimer()
        }
    }
    
    init(place: CommonPlaceInfo, subInfoVC: SubInfoViewController){
        self.place = place
        self.subInfoVC = subInfoVC
        super.init()
    }
    
    // MARK: - LifeCycle
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateMapCameraPos()
        resetScrollPos()
    }
}

// MARK: - Helper Method
extension MainInfoViewController {
    private func configureMainInfoView() {
        mainInfoView.nameLabel.text = place.title
        mainInfoView.layer.cornerRadius = 10
        mainInfoView.clipsToBounds = true
        
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
    
    private func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(resetScrollPos), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    private func addChildVC() {
        addChild(subInfoVC)
        mainInfoView.subInfoView.addSubview(subInfoVC.view)

        subInfoVC.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        subInfoVC.didMove(toParent: self)
    }
}

// MARK: - GalleryCollectionView
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
    
    @objc private func resetScrollPos() {
        guard let index = dataSource.indexPath(for: originCount) else { return }
        
        mainInfoView.galleryView.collectionView.scrollToItem(at: index, at: .centeredHorizontally, animated: false)
        mainInfoView.galleryView.pageLabel.text = "1 / \(originCount)"
    }
    
    private func updateSnapshot() {
        let count = galleryImages.count
        
        var snapshot = NSDiffableDataSourceSnapshot<Int, Int>()
        snapshot.appendSections([0])
        snapshot.appendItems([Int].init(0..<count))
        
        dataSource.apply(snapshot)
    }
    
    private func fetchGalleryImages() {
        realm.fetchPlaceImages(contentId: place.contentId) { [weak self] in
            self?.galleryImages = $0 + $0 + $0
            self?.mainInfoView.galleryView.isHidden = $0.count > 0 ? false : true
        }
    }
    
    // MARK: - Delegate Method
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let width = mainInfoView.galleryView.collectionView.frame.width
        let offset = scrollView.contentOffset.x
        let pageIndex = Int((offset / width).rounded()) % originCount
        
        mainInfoView.galleryView.pageLabel.text  = "\(pageIndex+1) / \(originCount)"
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        autoScrollTimer.invalidate()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let collectionView = mainInfoView.galleryView.collectionView
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        
        guard var index = collectionView.indexPathForItem(at: visiblePoint)?.row else { return }
        
        if index == originCount * 2 {
            index = originCount
        } else if index == originCount - 1 {
            index = 2*originCount - 1
        }
        
        collectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: .centeredHorizontally, animated: false)
        
        if !autoScrollTimer.isValid {
            activateAutoScrollTimer()
        }
        
        scrollView.isScrollEnabled = true
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let offset = targetContentOffset.pointee.x
        let width = scrollView.bounds.width
        let count = Double(originCount)
        
        if offset == 2*count*width || offset == (count-1)*width {
            print("🥹🥹 감속을 완료해야해! 🥹🥹")
            scrollView.isScrollEnabled = false
        }
    }
}
