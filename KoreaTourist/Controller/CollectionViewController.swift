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
    
    enum Section: Int, CaseIterable {
        
        case region, place
        
    }
    
    let collectionView = CollectionView()
    
    var regionList: Results<AreaCode>? {
        didSet {
//            collectionView.placeItemView.reloadSections([0])
            updateSnapshot()
        }
    }
    
    var placeList: Results<CommonPlaceInfo>? {
        didSet {
            collectionView.placeItemView.backgroundView = placeList?.count ?? 0 > 0 ? nil : collectionView.backgroundView
//            collectionView.placeItemView.reloadSections([1])
            updateSnapshot()
        }
    }
    
    var dataSource: UICollectionViewDiffableDataSource<Section, Int>!
    
    override func loadView() {
        view = collectionView
        collectionView.placeItemView.delegate = self
//        collectionView.placeItemView.dataSource = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        fetchPlaceList()
        fetchAreaList()
//        updateSnapshot()
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
        
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView.placeItemView) { [unowned self] collectionView, indexPath, itemIdentifier in
            
            let section = Section(rawValue: indexPath.section)
            
            let cell = section == .region ? collectionView.dequeueConfiguredReusableCell(using: categoryCellRegistration, for: indexPath, item: regionList![indexPath.row]) :
            collectionView.dequeueConfiguredReusableCell(using: placeCellRegistration, for: indexPath, item: placeList![indexPath.row])
            
            return cell
            
        }
        
    }
    
    func updateSnapshot() {
        
        let regionCount = regionList?.count ?? 0
        let placeCount = placeList?.count ?? 0
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Int>()
        snapshot.appendSections([Section.region, Section.place])
        snapshot.appendItems([Int](0..<regionCount), toSection: Section.region)
        snapshot.appendItems([Int](regionCount..<regionCount + placeCount), toSection: Section.place)
        dataSource.apply(snapshot)
        
    }
    
    func fetchAreaList() {
        
        realm.fetchAreaCode { [weak self] codeList in
            self?.regionList = codeList
        }
//        print(regionList.count)
    }
    
    func fetchPlaceList() {
        
        placeList = realm.fetchPlaces(type: CommonPlaceInfo.self).where({ $0.discoverDate != nil}).sorted(byKeyPath: "discoverDate", ascending: false)
        
    }
    
    override func configureNavigationItem() {
        
        title = "나의 컬렉션"
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        navigationItem.largeTitleDisplayMode = .always
        
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
        
    }
    
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
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            
            if let regionId = regionList?[indexPath.row].id {
                placeList = realm.fetchPlaces(type: CommonPlaceInfo.self).where {
                    $0.discoverDate != nil && $0.areaCode == regionId
                }.sorted(byKeyPath: "discoverDate", ascending: false)
            }
            
        } else {
            
            if let place = placeList?[indexPath.row] {
                
                let vc = DetailViewController(place: place)
                
                navigationController?.pushViewController(vc, animated: true)
                
            }
            
        }
    }
    
    /*
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if indexPath.section == 0 {
            
            let label = CategoryCell.SizingLabel
            
            label.text = regionList?[indexPath.row].name ?? ""
            
            return label.intrinsicContentSize
            
        } else {
            
            let space = (collectionViewLayout as! UICollectionViewFlowLayout).minimumInteritemSpacing
            
            if let orient = view.window?.windowScene?.interfaceOrientation {
                
                let width = collectionView.bounds.width
                
                let sizeValue = orient.isLandscape ? (width - 6*space) / 5 : (width - 4*space) / 3
                
                return CGSize(width: sizeValue, height: sizeValue)
                
            } else {
                return .zero
            }
            
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else { return 0 }
        
        let space = layout.minimumInteritemSpacing
        
        return section == 0 ? space/2 : space
        
    }
     */
    
    /*
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CollectionHeaderView.reuseIdentifier, for: indexPath) as? CollectionHeaderView else { return UICollectionReusableView() }
        
        let places = realm.fetchPlaces(type: CommonPlaceInfo.self)
        let discovered = places.where { $0.discoverDate != nil }
        
        view.label.text = "발견한 장소: \(discovered.count) 찾은 장소: \(places.count)"
        
        return view
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        section == 0 ? CGSize(width: 0, height: 32) : .zero
        
    }
    */
}
