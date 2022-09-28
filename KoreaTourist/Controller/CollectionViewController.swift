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
    
    var placeList: Results<CommonPlaceInfo>! {
        didSet {
            collectionView.placeItemView.reloadSections([0])
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
    }
    
    func fetchPlaceList() {
        
        placeList = realm.fetchPlaces(type: CommonPlaceInfo.self).where({ $0.discoverDate != nil})
        
    }
    
    override func configureNavigationItem() {
        
        title = "나의 컬렉션"
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        navigationItem.largeTitleDisplayMode = .always
        
        let closeButton = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(touchCloseButton(_:)))
        
        navigationItem.leftBarButtonItem = closeButton
        
    }
    
    @objc func touchCloseButton(_ sender: UIBarButtonItem) {
        
        self.dismiss(animated: true)
        
    }
    

}

extension CollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        placeList.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PlaceCollectionCell.reuseIdentifier, for: indexPath) as? PlaceCollectionCell else { return UICollectionViewCell() }
        
        let place = placeList[indexPath.row]
        cell.imageView.kf.setImage(with: URL(string: place.thumbnail))
        
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let place = placeList[indexPath.row]
        
        let vc = DetailViewController(place: place)
        
        navigationController?.pushViewController(vc, animated: true)
        
        /*
        if place.intro != nil {
            let vc = DetailViewController(place: place)
            navigationController?.pushViewController(vc, animated: true)
        } else {
            APIManager.shared.requestPlaceIntro(contentId: place.contentId) { [weak self] data in
                self?.realm.addPlaceIntro(with: place, using: data)
                let vc = DetailViewController(place: place)
                self?.navigationController?.pushViewController(vc, animated: true)
            }
        }
        */
        
    }
    
    
    
}
