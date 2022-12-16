//
//  GalleryView.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2022/11/02.
//

import UIKit
import Then
import SnapKit

class GalleryView: BaseView {
    let pageLabel = BasePaddingLabel(padding: UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 10))
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
    
    init() {
        super.init(frame: .zero)
        configureSubviews()
    }
    
    private func configureSubviews() {
        pageLabel.font = .systemFont(ofSize: 14, weight: .medium)
        pageLabel.layer.cornerRadius = 14
        pageLabel.textColor = .white
        pageLabel.backgroundColor = .black.withAlphaComponent(0.6)
        pageLabel.clipsToBounds = true
        pageLabel.textAlignment = .center
        pageLabel.numberOfLines = 1
        
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true
        collectionView.backgroundColor = .systemGroupedBackground
    }
     
    override func addSubviews() {
        [collectionView, pageLabel].forEach {
            addSubview($0)
        }
    }
    
    override func addConstraint() {
        collectionView.snp.makeConstraints {
            $0.leading.trailing.bottom.top.equalToSuperview()
            $0.height.equalTo(collectionView.snp.width).multipliedBy(0.75)
        }
        
        pageLabel.snp.makeConstraints {
            $0.bottom.equalTo(-12)
            $0.centerX.equalToSuperview()
        }
    }
    
}

extension GalleryView {
    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.scrollDirection = .horizontal
        config.contentInsetsReference = .none
        
        let layout = UICollectionViewCompositionalLayout(section: section, configuration: config)
        
        return layout
    }
}
