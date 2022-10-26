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
    
    lazy var placeItemView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
    
    
    func createLayout() -> UICollectionViewLayout {
        
        let layout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            
            let sectionKind = CollectionViewController.SectionLayoutKind(rawValue: sectionIndex)!
            
            let item: NSCollectionLayoutItem
            let group: NSCollectionLayoutGroup
            let section: NSCollectionLayoutSection
            let space: CGFloat = 4
            
            switch sectionKind {
            case .region:
                let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(44), heightDimension: .estimated(44))
                item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.edgeSpacing = NSCollectionLayoutEdgeSpacing(leading: .none, top: .none, trailing: .flexible(space), bottom: .none)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44))
                group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = space
                section.contentInsets = NSDirectionalEdgeInsets(value: space*2)
                return section
    
            case .place:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.3333), heightDimension: .fractionalHeight(1.0))
                item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(value: space)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(0.3333))
                group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(value: space)
                
                return section
            }
            
        }
        
        
        let config = UICollectionViewCompositionalLayoutConfiguration().then {
            
            let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(30))
            
            let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: size, elementKind: CollectionViewController.layoutHeaderElementKind, alignment: .top)
            
            $0.boundarySupplementaryItems = [header]
        }
        
        layout.configuration = config
        
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
