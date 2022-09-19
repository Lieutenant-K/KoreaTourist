//
//  ImageHeaderView.swift
//  KakaoMap
//
//  Created by 김윤수 on 2022/09/19.
//

import UIKit
import SnapKit

final class ImageHeaderView: BaseView {

    let pageControl: UIPageControl = {
        let control = UIPageControl()
        control.hidesForSinglePage = true
        control.numberOfPages = 1
        return control
    }()
    
    let collectionView: UICollectionView
    
    private func configureCollectionView() {
        
        collectionView.backgroundColor = .clear
        collectionView.isPagingEnabled = true
        
    }
    
    override func setBackground() {
        backgroundColor = .clear
    }
    
    override func addSubviews() {
        
        addSubview(collectionView)
        addSubview(pageControl)
    }
    
    override func addConstraint() {
        
        collectionView.snp.makeConstraints { $0.edges.equalToSuperview() }
        pageControl.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(-14)
        }
    }
    
    init(itemSize: CGSize) {
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = itemSize
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        super.init(frame: .zero)
        
        configureCollectionView()
        
    }
    
}
