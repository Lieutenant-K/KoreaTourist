//
//  EventInfoCell.swift
//  KakaoMap
//
//  Created by 김윤수 on 2022/09/18.
//

import UIKit

final class EventInfoCell: BaseInfoCell {
    
    let eventView = LabelStackView(title: "행사")
    let eventAgeView = LabelStackView(title: "가능 연령")
    
    lazy var verticalStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [eventView, eventAgeView])
        stack.axis = .vertical
        stack.distribution = .fill
        stack.spacing = 8
        return stack
    }()
    
    func inputData(data: TourPlaceInfo.EventData){
        
//        guard let data = data else { return }
        
        eventView.contentLabel.text = data.event
        eventAgeView.contentLabel.text = data.eventAge
    }
    
    func checkValidation() {
        var isDisplay = false
        [eventView, eventAgeView].forEach { view in
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
        iconImageView.image = UIImage(systemName: "exclamationmark.circle.fill")
        titleLabel.text = "행사 안내"
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
