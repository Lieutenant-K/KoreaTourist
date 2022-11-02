//
//  GalleryView.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2022/11/02.
//

import UIKit

class GalleryView: BaseView {

    let titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 18, weight: .medium)
        $0.numberOfLines = 0
        $0.textAlignment = .left
        $0.text = "갤러리"
    }
    
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    
    override func addSubviews() {
        [titleLabel, collectionView].forEach {
            addSubview($0)
        }
    }
    
    override func addConstraint() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(12)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(14)
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(220)
        }
        
        self.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(0)
        }
    }
    
}
