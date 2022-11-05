//
//  GalleryView.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2022/11/02.
//

import UIKit

class GalleryView: BaseView {
    
    /*
    let titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 18, weight: .medium)
        $0.numberOfLines = 0
        $0.textAlignment = .left
        $0.text = "갤러리"
    }
     */
    
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout()).then {
        $0.backgroundColor = .systemGroupedBackground
    }
    
    func createLayout() -> UICollectionViewLayout {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = .fixed(20)
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
        
    }
    
    override func addSubviews() {
        [collectionView].forEach {
            addSubview($0)
        }
    }
    
    override func addConstraint() {
        /*
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(12)
        }*/
        
        collectionView.snp.makeConstraints { make in
//            make.top.equalTo(titleLabel.snp.bottom).offset(14)
            make.leading.trailing.bottom.top.equalToSuperview()
            make.height.equalTo(collectionView.snp.width).multipliedBy(0.75)
        }
        
//        self.snp.makeConstraints { make in
//            make.height.greaterThanOrEqualTo(0)
//        }
    }
    
}
