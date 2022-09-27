//
//  PlaceCollectionCell.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2022/09/28.
//

import UIKit
import Then

class PlaceCollectionCell: UICollectionViewCell {
    
    let imageView = UIImageView().then {
        $0.layer.cornerRadius = 10
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
    }
    
    private func configureCell() {
        layer.cornerRadius = 10
        backgroundColor = .systemBlue
        
        contentView.addSubview(imageView)
        
        imageView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureCell()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
    
}
