//
//  CategoryCell.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2022/09/30.
//

import UIKit
import Then

class CategoryCell: UICollectionViewCell {
    let label = BasePaddingLabel(padding: UIEdgeInsets(top: 4, left: 10, bottom: 4, right: 10)).then {
        $0.numberOfLines = 1
        $0.textAlignment = .center
        $0.textColor = .label
        $0.layer.cornerRadius = 12
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.label.cgColor
        $0.clipsToBounds = true
    }
    
    override var isSelected: Bool {
        didSet {
            updateLabelAppearance()
        }
    }
    
    func updateLabelAppearance() {
        label.textColor = isSelected ? .systemBackground : .label
        label.layer.borderColor = isSelected ? UIColor.systemBackground.cgColor : UIColor.label.cgColor
        label.backgroundColor = isSelected ? .label : .systemBackground
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        updateLabelAppearance()
    }
    
    private func configureCell() {
        contentView.addSubview(label)
        label.snp.makeConstraints { $0.edges.equalToSuperview() }
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
