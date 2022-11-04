//
//  OtherDetailInfoCell.swift
//  KakaoMap
//
//  Created by 김윤수 on 2022/09/18.
//

import UIKit

final class OtherDetailInfoCell: BaseInfoCell {
    
    let contactView = LabelStackView(title: "문의 및 안내")
    let capacityView = LabelStackView(title: "수용인원")
    let parkingView = LabelStackView(title: "주차장 여부")
    let strollerView = LabelStackView(title: "유모차 대여 여부")
    let creditCardView = LabelStackView(title: "신용카드 가능 여부")
    let petView = LabelStackView(title: "애완동물 가능 여부")
    
    lazy var viewList: [LabelStackView] = {
        [contactView, capacityView, parkingView, strollerView, creditCardView, petView]
    }()
    
    lazy var verticalStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: viewList)
        stack.axis = .vertical
        stack.distribution = .fill
        stack.spacing = 8
        return stack
    }()
    
    func inputData(data: TourPlaceInfo.ServiceData){
        
//        guard let data = data else { return }
        contactView.contentLabel.text = data.contact
        capacityView.contentLabel.text = data.capacity
        parkingView.contentLabel.text = data.parking
        strollerView.contentLabel.text = data.stroller
        creditCardView.contentLabel.text = data.creditCard
        petView.contentLabel.text = data.pet
    }
    
    func checkValidation() {
        var isDisplay = false
        viewList.forEach { view in
            if view.contentLabel.isValidate {
                view.isHidden = false
                isDisplay = isDisplay || true
            } else {
                view.isHidden = true
                isDisplay = isDisplay || false
            }
        }
        isHidden = !isDisplay
        
    }
    
    
    override func configureCell() {
        iconImageView.image = UIImage(systemName: "person.fill")
        titleLabel.text = "서비스"
    }
    
    override func addSubviews() {
        super.addSubviews()
        contentView.addSubview(verticalStackView)
        
    }
    
    override func addConstraints() {
        super.addConstraints()
        
        verticalStackView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.leading.bottom.trailing.equalTo(contentView).inset(18)
        }
        
    }

}
