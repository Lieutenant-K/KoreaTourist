//
//  DetailImageCell.swift
//  KakaoMap
//
//  Created by 김윤수 on 2022/09/19.
//

import UIKit
import SnapKit

class DetailImageCell: UICollectionViewCell {
    
    let imageView: UIImageView = {
       let view = UIImageView()
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private func addSubviews() {
        contentView.addSubview(imageView)
    }
    
    private func addConstraints() {
        imageView.snp.makeConstraints { $0.leading.trailing.top.bottom.equalTo(contentView) }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        addConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
