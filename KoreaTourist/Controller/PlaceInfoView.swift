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
    
    let imageContainer = UIView().then {
        $0.backgroundColor = .secondarySystemBackground
    }
    
    let containerView = UIView().then {
        $0.layer.shadowOffset = CGSize(width: 0, height: 0)
        $0.layer.shadowOpacity = 0.5
        $0.layer.cornerRadius = 10
    }
    
    func addConstraint() {
        
        imageContainer.snp.makeConstraints { make in
            make.trailing.leading.equalTo(frameLayoutGuide)
            make.top.equalTo(contentLayoutGuide)
//            make.height.greaterThanOrEqualTo(0)
            make.height.equalTo(imageContainer.snp.width).multipliedBy(0.75)
        }
        
        /*
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(contentLayoutGuide)
            make.width.equalTo(frameLayoutGuide)
            make.height.equalTo(frameLayoutGuide).priority(.low)
        }
         */
        
        /*
        imageView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(imageView.snp.width).multipliedBy(0.75)
        }
        */
        
        containerView.snp.makeConstraints { make in
            make.top.equalTo(imageContainer.snp.bottom).offset(-100)
            
            make.leading.trailing.equalTo(frameLayoutGuide).inset(20)
            make.bottom.equalTo(contentLayoutGuide)
            
            make.height.greaterThanOrEqualTo(0)
//           make.top.equalTo(imageView.snp.bottom).offset(-100)
//            make.height.greaterThanOrEqualTo(0)
//            make.height.equalTo(900)
        }
        
//        containerView.layer.cornerRadius = 20
    }
    
    func addSubviews() {
        addSubview(imageContainer)
        addSubview(containerView)
        
        //contentView.addSubview(imageView)
        //contentView.addSubview(containerView)
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
