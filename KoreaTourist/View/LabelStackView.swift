//
//  LabelContentView.swift
//  KakaoMap
//
//  Created by 김윤수 on 2022/09/18.
//

import UIKit
import SnapKit
import Then

final class LabelStackView: UIStackView {
    
    let titleLabel = UILabel().then {
        
        $0.font = .systemFont(ofSize: 16, weight: .medium)
        $0.textAlignment = .left
        $0.textColor = .label
        $0.numberOfLines = 1
        $0.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        $0.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        $0.setContentHuggingPriority(.defaultHigh, for: .vertical)
        
    }
    
    let contentLabel = UILabel().then {
        
        $0.font = .systemFont(ofSize: 16, weight: .regular)
        $0.textAlignment = .left
        $0.textColor = .label
        $0.numberOfLines = 0
        $0.lineBreakMode = .byWordWrapping
        $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
        $0.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        $0.setContentHuggingPriority(.defaultLow, for: .vertical)
//        view.adjustsFontSizeToFitWidth = true
        
    }
    
    func updateAxisUsingContentLines() {
        changeAxis(axis: contentLabel.countLines() > 1 ? .vertical : .horizontal)
    }
    
    private func changeAxis(axis: NSLayoutConstraint.Axis) {
        self.axis = axis
        distribution = .fill
        alignment = axis == .horizontal ? .top : .fill
    }
    
    private func configureStackView(axis: NSLayoutConstraint.Axis) {
        changeAxis(axis: axis)
        
        spacing = 6
        
        addArrangedSubview(titleLabel)
        addArrangedSubview(contentLabel)
    }
    
    init(title: String, content: String, axis: NSLayoutConstraint.Axis = .horizontal) {
        super.init(frame: .zero)
        titleLabel.text = title
        contentLabel.text = content
        configureStackView(axis: axis)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
