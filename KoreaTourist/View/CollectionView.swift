//
//  CollectionView.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2022/09/28.
//

import UIKit
import Then
import SnapKit

class CollectionView: BaseView {
    
    lazy var backgroundView = UIView().then { view in
        
        let label = UILabel().then {
            $0.font = .systemFont(ofSize: 24, weight: .semibold)
            $0.text = "아직 발견된 장소가 없어요 :("
            $0.textColor = .placeholderText
            $0.textAlignment = .center
        }
        
        view.addSubview(label)
        label.snp.makeConstraints { $0.center.equalToSuperview() }
    }
    
    let placeItemView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
        
        let layout = $0.collectionViewLayout as! UICollectionViewFlowLayout
        let space: CGFloat = 8
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = space
        layout.minimumLineSpacing = space
        layout.sectionInset = UIEdgeInsets(top: space, left: space, bottom: space, right: space)
        let sizeValue = (UIScreen.main.bounds.width - 4*space) / 3
        layout.itemSize = CGSize(width: sizeValue, height: sizeValue)
        
        $0.register(CollectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CollectionHeaderView.reuseIdentifier)
        $0.register(PlaceCollectionCell.self, forCellWithReuseIdentifier: PlaceCollectionCell.reuseIdentifier)
        $0.register(CategoryCell.self, forCellWithReuseIdentifier: CategoryCell.reuseIdentifier)
        
        
    }
    
    override func addSubviews() {
        addSubview(placeItemView)
    }
    
    override func addConstraint() {
        placeItemView.snp.makeConstraints { $0.edges.equalTo(safeAreaLayoutGuide)
        }
    }
    
}
