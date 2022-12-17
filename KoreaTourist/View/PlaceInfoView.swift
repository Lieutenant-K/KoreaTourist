//
//  ScrollView.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2022/11/01.
//

import UIKit
import SnapKit

final class PlaceInfoView: UIScrollView {
    let imageContainer = UIView()
    let containerView = UIView()
    
    private func addConstraint() {
        imageContainer.snp.makeConstraints { make in
            make.trailing.leading.equalTo(frameLayoutGuide)
            make.top.equalTo(contentLayoutGuide)
            make.height.equalTo(imageContainer.snp.width).multipliedBy(0.75)
        }
        
        containerView.snp.makeConstraints { make in
            make.top.equalTo(imageContainer.snp.centerY).offset(-100)
            make.leading.trailing.equalTo(frameLayoutGuide).inset(20)
            make.bottom.equalTo(contentLayoutGuide).offset(-50)
            make.height.greaterThanOrEqualTo(0)
        }
    }
    
    private func configureSubviews() {
        addSubview(imageContainer)
        addSubview(containerView)
        
        backgroundColor = .systemBackground
        imageContainer.backgroundColor = .secondarySystemBackground
        containerView.layer.shadowOffset = CGSize(width: 0, height: 0)
        containerView.layer.shadowOpacity = 0.5
        containerView.layer.cornerRadius = 10
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureSubviews()
        addConstraint()
    }
}
