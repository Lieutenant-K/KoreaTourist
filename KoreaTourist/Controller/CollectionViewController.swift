//
//  CollectionViewController.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2022/09/28.
//

import UIKit
import RealmSwift
import Kingfisher

class CollectionViewController: BaseViewController {

    let collectionView = CollectionView()
    
    var regionList: Results<AreaCode>? {
        didSet { updateSnapshot() }
    }
    
    var placeList: Results<CommonPlaceInfo>? {
        didSet {
            collectionView.placeItemView.backgroundView = placeList?.count ?? 0 > 0 ? nil : collectionView.backgroundView
            updateSnapshot()
        }
    }
    
    var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, Int>!
    
    // MARK: - Life Cycle
    override func loadView() {
        view = collectionView
        collectionView.placeItemView.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        fetchAreaList()
    }
    
    override func configureNavigationItem() {
        title = "나의 컬렉션"
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let closeButton = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(touchCloseButton(_:)))
        
        let settingButton = UIBarButtonItem(image: UIImage(systemName: "gearshape.fill"), style: .plain, target: self, action: #selector(touchSettingButton(_:)))
        
        let button  = UIButton(type: .system)
        button.setImage(.map, for: .normal)
        button.addTarget(self, action: #selector(touchWorldMapButton(_:)), for: .touchUpInside)
        button.snp.makeConstraints {$0.size.equalTo(27) }
        let worldMapButton = UIBarButtonItem(customView: button)
        
        navigationItem.leftBarButtonItem = closeButton
        navigationItem.rightBarButtonItems = [settingButton, worldMapButton]
        navigationItem.backButtonTitle = "뒤로"
        navigationItem.largeTitleDisplayMode = .always
    }
}

// MARK: - Helper Method
extension CollectionViewController {
    func updateSnapshot() {
        let regionCount = regionList?.count ?? 0
        let placeCount = placeList?.count ?? 0
        
        var snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, Int>()
        snapshot.appendSections([SectionLayoutKind.region, SectionLayoutKind.place])
        snapshot.appendItems([Int](0..<regionCount), toSection: SectionLayoutKind.region)
        snapshot.appendItems([Int](regionCount..<regionCount + placeCount), toSection: SectionLayoutKind.place)
        
        dataSource.apply(snapshot)
    }
    
    func fetchAreaList() {
        realm.fetchAreaCode { [weak self] codeList in
            self?.regionList = codeList
            self?.fetchPlaceList()
        }
    }
    
    func fetchPlaceList() {
        placeList = realm.loadPlaces(type: CommonPlaceInfo.self).where({ $0.discoverDate != nil}).sorted(byKeyPath: "discoverDate", ascending: false)
    }
}

// MARK: - Action Method
extension CollectionViewController {
    @objc func touchCloseButton(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
    @objc func touchSettingButton(_ sender: UIBarButtonItem) {
        navigationController?.pushViewController(SettingViewController(), animated: true)
    }
    
    @objc func touchWorldMapButton(_ sender: UIBarButtonItem) {
        navigationController?.pushViewController(WorldMapViewController(), animated: true)
    }
}

// MARK: - CollectionView DataSource, Delegate
extension CollectionViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    static let layoutHeaderElementKind = "layout-header-element-kind"
    
    enum SectionLayoutKind: Int, CaseIterable {
        
        case region, place
        
    }
    
    func configureCollectionView() {
        
        let categoryCellRegistration = UICollectionView.CellRegistration<CategoryCell, AreaCode> { cell, indexPath, itemIdentifier in
            
            cell.label.text = itemIdentifier.name
            
        }
        
        let placeCellRegistration = UICollectionView.CellRegistration<PlaceCollectionCell, CommonPlaceInfo> { cell, indexPath, itemIdentifier in
            
            if itemIdentifier.isImageIncluded {
                
                cell.imageView.kf.setImage(with: URL(string: itemIdentifier.thumbnail), options: [.transition(.fade(0.5))])
                cell.imageView.contentMode = .scaleAspectFill
                
            } else {
                
                cell.imageView.image = UIImage(systemName: "photo")
                cell.imageView.contentMode = .center
                
            }
            
        }
        
        let headerRegistration = UICollectionView.SupplementaryRegistration<CollectionHeaderView>(elementKind: Self.layoutHeaderElementKind) { [unowned self] supplementaryView, elementKind, indexPath in
            
            let places = realm.loadPlaces(type: CommonPlaceInfo.self)
            
            let discovered = places.where { $0.discoverDate != nil }
            
            supplementaryView.label.text = "발견한 장소: \(discovered.count) 찾은 장소: \(places.count)"
            
            
        }
        
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView.placeItemView) { [unowned self] collectionView, indexPath, itemIdentifier in
            
            let section = SectionLayoutKind(rawValue: indexPath.section)
            
            let cell = section == .region ? collectionView.dequeueConfiguredReusableCell(using: categoryCellRegistration, for: indexPath, item: regionList![indexPath.row]) :
            collectionView.dequeueConfiguredReusableCell(using: placeCellRegistration, for: indexPath, item: placeList![indexPath.row])
            
            return cell
            
        }
        
        dataSource.supplementaryViewProvider = { collectionView, elementKind, indexPath in
            
            collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
            
        }
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let sectionKind = SectionLayoutKind(rawValue: indexPath.section)!
        
        switch sectionKind {
        case .region:
            if let regionId = regionList?[indexPath.row].id {
                placeList = realm.loadPlaces(type: CommonPlaceInfo.self).where {
                    $0.discoverDate != nil && $0.areaCode == regionId
                }.sorted(byKeyPath: "discoverDate", ascending: false)
            }
        case .place:
            if let place = placeList?[indexPath.row] {
                let sub = SubInfoViewController(place: place)
                let main = MainInfoViewController(place: place, subInfoVC: sub)
                let vc = PlaceInfoViewController(place: place, mainInfoVC: main)
                
                navigationController?.pushViewController(vc, animated: true)
            }
            
        }
    }
    
}
