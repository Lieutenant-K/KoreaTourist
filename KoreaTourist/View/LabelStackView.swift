//
//  LabelContentView.swift
//  KakaoMap
//
//  Created by 김윤수 on 2022/09/18.
//

import UIKit
import SnapKit

class LabelStackView: UIStackView {
    
    let titleLabel: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 16, weight: .medium)
        view.textAlignment = .left
        view.textColor = .label
        view.numberOfLines = 1
        view.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        view.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        view.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        view.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return view
    }()
    
    let contentLabel: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 16, weight: .light)
        view.textAlignment = .left
        view.textColor = .label
        view.numberOfLines = 1
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        view.setContentHuggingPriority(.defaultLow, for: .horizontal)
        view.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        view.setContentHuggingPriority(.defaultLow, for: .vertical)
        view.adjustsFontSizeToFitWidth = true
        return view
    }()
    
    func configureStackView(axis: NSLayoutConstraint.Axis) {
        self.axis = axis
        distribution = .fill
        alignment = .fill
        spacing = 10
        addArrangedSubview(titleLabel)
        addArrangedSubview(contentLabel)
        
        if axis == .vertical {
            contentLabel.numberOfLines = 0
        }
    }
    
    init(title: String, axis: NSLayoutConstraint.Axis = .horizontal) {
        super.init(frame: .zero)
        titleLabel.text = title
        configureStackView(axis: axis)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
