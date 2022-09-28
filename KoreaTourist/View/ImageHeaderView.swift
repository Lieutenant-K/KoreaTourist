//
//  ImageHeaderView.swift
//  KakaoMap
//
//  Created by 김윤수 on 2022/09/19.
//

import UIKit
import SnapKit
import Then

final class ImageHeaderView: BaseView {

    let pageControl: UIPageControl = {
        let control = UIPageControl()
        control.hidesForSinglePage = true
        control.numberOfPages = 1
        return control
    }()
    
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout()).then {
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        $0.backgroundColor = .clear
        $0.isPagingEnabled = true
        $0.showsHorizontalScrollIndicator = false
        $0.collectionViewLayout = layout
    }
    
    /*
    private func configureCollectionView() {
        
        collectionView.backgroundColor = .clear
        collectionView.isPagingEnabled = true
        
    }
    */
    
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
        super.init(frame: .zero)
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = itemSize
//        configureCollectionView()
        
    }
    
}
