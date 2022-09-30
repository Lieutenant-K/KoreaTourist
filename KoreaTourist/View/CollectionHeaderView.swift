//
//  CollectionHeaderView.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2022/10/01.
//

import UIKit
import Then
import SnapKit

class CollectionHeaderView: UICollectionReusableView {
    
    let label = BasePaddingLabel(padding: UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)).then {
        $0.numberOfLines = 1
        $0.font = .systemFont(ofSize: 18, weight: .semibold)
    }
    
    func configureView() {
        
        addSubview(label)
        
        label.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
