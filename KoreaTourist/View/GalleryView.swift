//
//  GalleryView.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2022/11/02.
//

import UIKit
import Then

class GalleryView: BaseView {
    
    /*
    let titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 18, weight: .medium)
        $0.numberOfLines = 0
        $0.textAlignment = .left
        $0.text = "갤러리"
    }
     */
    
    let pageLabel = BasePaddingLabel(padding: UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 10)).then {
        $0.font = .systemFont(ofSize: 14, weight: .medium)
        $0.layer.cornerRadius = 14
        $0.textColor = .white
        $0.backgroundColor = .black.withAlphaComponent(0.6)
        $0.clipsToBounds = true
        $0.textAlignment = .center
        $0.numberOfLines = 1

    }
    
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout()).then {
        $0.showsHorizontalScrollIndicator = false
        $0.isPagingEnabled = true
        $0.backgroundColor = .systemGroupedBackground
    
    }
    
    
    func createLayout() -> UICollectionViewLayout {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.visibleItemsInvalidationHandler = { [weak self] visibleItems, scrollOffset, layoutEnvironment in
            
            // 호출 시 마다 수직 스크롤이 자동으로 발생하는 이슈
            
            guard let weakSelf = self else { return }
            
            let width = layoutEnvironment.container.contentSize.width
            
            let originCount = weakSelf.collectionView.numberOfItems(inSection: 0) / 3
            
            let offset = scrollOffset.x
            
            let pageIndex = Int((offset / width).rounded())
            
            if originCount != 0 {
                weakSelf.pageLabel.text = "\(pageIndex % originCount + 1) / \(originCount)"
            }
             
        }
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.scrollDirection = .horizontal
        config.contentInsetsReference = .none
        
        let layout = UICollectionViewCompositionalLayout(section: section, configuration: config)
        
        return layout
        
    }
     
    
    override func addSubviews() {
        [collectionView, pageLabel].forEach {
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
        
        pageLabel.snp.makeConstraints { make in
            make.bottom.equalTo(-12)
            make.centerX.equalToSuperview()
//            make.trailing.bottom.equalToSuperview().inset(12)
        }
        
//        self.snp.makeConstraints { make in
//            make.height.greaterThanOrEqualTo(0)
//        }
    }
    
}
