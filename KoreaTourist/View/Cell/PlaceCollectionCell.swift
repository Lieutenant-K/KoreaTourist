//
//  PlaceCollectionCell.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2022/09/28.
//

import UIKit
import Then

class PlaceCollectionCell: UICollectionViewCell {
    
    let corner: CGFloat = 10
    
    lazy var imageView = UIImageView().then {
        $0.layer.cornerRadius = corner
        $0.contentMode = .scaleAspectFill
        $0.tintColor = .secondaryLabel
//        $0.clipsToBounds = true
    }
    
    private func configureCell() {
        layer.cornerRadius = corner
//        backgroundColor = .systemBlue
        
        let blur = UIBlurEffect(style: .systemUltraThinMaterial)
        let visual = UIVisualEffectView(effect: blur)
        visual.layer.cornerRadius = corner
        visual.clipsToBounds = true
        contentView.addSubview(visual)
        
        visual.snp.makeConstraints { $0.edges.equalToSuperview() }
        visual.contentView.addSubview(imageView)
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
