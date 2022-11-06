//
//  ScrollView.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2022/11/01.
//

import UIKit
import Then
import SnapKit

class PlaceInfoView: UIScrollView {
    
    let contentView = UIView().then {
        $0.backgroundColor = .systemBackground
    }
    
    let imageView = UIImageView().then {
        $0.backgroundColor = .secondarySystemBackground
    }
    
    let containerView = UIView().then {
        $0.layer.shadowOffset = CGSize(width: 0, height: 0)
        $0.layer.shadowOpacity = 0.5
    }
    /*
    UIView().then {
        $0.backgroundColor = .gray
        let view = CommonInfoView()
        $0.addSubview(view)
        view.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
        }
    }
     */
    
    func addConstraint() {
        
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(contentLayoutGuide)
            make.width.equalTo(frameLayoutGuide)
            make.height.equalTo(frameLayoutGuide).priority(.low)
        }
        
        imageView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(250)
        }
        
        containerView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview().inset(20)
            make.top.equalTo(imageView.snp.bottom).offset(-100)
//            make.height.greaterThanOrEqualTo(0)
//            make.height.equalTo(900)
        }
        
        containerView.layer.cornerRadius = 20
    }
    
    func addSubviews() {
        addSubview(contentView)
        contentView.addSubview(imageView)
        contentView.addSubview(containerView)
    }
    
    func setBackground() {
        backgroundColor = .systemBackground
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        addConstraint()
        setBackground()
    }
}
