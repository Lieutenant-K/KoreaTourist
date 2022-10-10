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
        didSet {
            collectionView.placeItemView.reloadSections([0])
        }
    }
    
    var placeList: Results<CommonPlaceInfo>? {
        didSet {
            collectionView.placeItemView.backgroundView = placeList?.count ?? 0 > 0 ? nil : collectionView.backgroundView
            collectionView.placeItemView.reloadSections([1])
        }
    }
    
    override func loadView() {
        view = collectionView
        collectionView.placeItemView.delegate = self
        collectionView.placeItemView.dataSource = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchPlaceList()
        fetchAreaList()
        
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
        
        let settingButton = UIBarButtonItem(image: UIImage(systemName: "gearshape"), style: .plain, target: self, action: #selector(touchSettingButton(_:)))
        
        let worldMapButton = UIBarButtonItem(image: UIImage(systemName: "map.fill"), style: .plain, target: self, action: #selector(touchWorldMapButton(_:)))
        
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
        
        navigationController?.pushViewController(UIViewController(), animated: true)
        
    }
    
    
}


// MARK: - CollectionView DataSource, Delegate
extension CollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        section == 0 ? (regionList?.count ?? 0) : (placeList?.count ?? 0)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.section == 0 {
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCell.reuseIdentifier, for: indexPath) as? CategoryCell else { return UICollectionViewCell() }
            
            if let region = regionList?[indexPath.row].name {
                cell.label.text = region
            }
            
            return cell
            
            
        } else {
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PlaceCollectionCell.reuseIdentifier, for: indexPath) as? PlaceCollectionCell else { return UICollectionViewCell() }
            
            if let place = placeList?[indexPath.row] {
                
                if place.isImageIncluded {
                    cell.imageView.kf.setImage(with: URL(string: place.thumbnail), options: [.transition(.fade(0.5))])
                    cell.imageView.contentMode = .scaleAspectFill
                } else {
                    cell.imageView.image = UIImage(systemName: "photo")
                    cell.imageView.contentMode = .center
                }
                
                
            }
            
            return cell
            
        }
        
    }
    
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
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if indexPath.section == 0 {
            
            let label = CategoryCell.SizingLabel
            
            label.text = regionList?[indexPath.row].name ?? ""
            
            return label.intrinsicContentSize
            
        } else {
            
            let layout = collectionViewLayout as! UICollectionViewFlowLayout
            
            return layout.itemSize
            
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else { return 0 }
        
        let space = layout.minimumInteritemSpacing
        
        return section == 0 ? space/2 : space
        
    }
    
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
    
}
