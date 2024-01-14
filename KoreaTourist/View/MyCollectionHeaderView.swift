//
//  CollectionHeaderView.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2022/10/01.
//

import UIKit
import Then
import SnapKit

final class MyCollectionHeaderView: UICollectionReusableView {
    private let label = BasePaddingLabel(padding: UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)).then {
        $0.numberOfLines = 1
        $0.font = .systemFont(ofSize: 18, weight: .semibold)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateLabel(discoveredCnt: Int, collectedCnt: Int) {
        self.label.text = "발견한 장소: \(discoveredCnt) 찾은 장소: \(collectedCnt)"
    }
}

extension MyCollectionHeaderView {
    private func configureView() {
        self.addSubview(label)
        self.label.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
