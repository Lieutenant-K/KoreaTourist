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
    
    lazy var placeItemView = UICollectionView(frame: .zero, collectionViewLayout: createLayout()).then { _ in
        
        /*
        let layout = $0.collectionViewLayout as! UICollectionViewFlowLayout
        let space: CGFloat = 8
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = space
        layout.minimumLineSpacing = space
        layout.sectionInset = UIEdgeInsets(top: space, left: space, bottom: space, right: space)
         */
        
//        let sizeValue = (UIScreen.main.bounds.width - 4*space) / 3
//        layout.itemSize = CGSize(width: sizeValue, height: sizeValue)
        
//        $0.register(CollectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CollectionHeaderView.reuseIdentifier)
//        $0.register(PlaceCollectionCell.self, forCellWithReuseIdentifier: PlaceCollectionCell.reuseIdentifier)
//        $0.register(CategoryCell.self, forCellWithReuseIdentifier: CategoryCell.reuseIdentifier)
        
        
    }
    
    
    func createLayout() -> UICollectionViewLayout {
        
        let layout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            
//            print(layoutEnvironment.container.contentSize)
            
            let itemSize = sectionIndex == 0 ? NSCollectionLayoutSize(widthDimension: .estimated(44), heightDimension: .estimated(44)) :
            NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.33), heightDimension: .fractionalWidth(0.33))
            
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let space = NSCollectionLayoutSpacing.flexible(4)
//            item.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0)
            
            if sectionIndex == 0 {
                item.edgeSpacing = NSCollectionLayoutEdgeSpacing(leading: space, top: space, trailing: space, bottom: space)
            } else {
                item.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4)
            }
            
            
            let height: NSCollectionLayoutDimension = sectionIndex == 0 ? .estimated(44) : .fractionalWidth(0.33)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: height)
            
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
//            group.interItemSpacing = space
            
            
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
//            section.interGroupSpacing = 20
            
            return section
            
        }
        
        return layout
    }
    
    
    override func addSubviews() {
        addSubview(placeItemView)
    }
    
    override func addConstraint() {
        placeItemView.snp.makeConstraints { $0.edges.equalTo(safeAreaLayoutGuide)
        }
    }
    
}
