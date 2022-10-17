//
//  TimeCell.swift
//  KakaoMap
//
//  Created by 김윤수 on 2022/09/18.
//

import UIKit

final class TimeInfoCell: BaseInfoCell {
    
    let openDateView = LabelStackView(title: "개장일")
    let restDateView = LabelStackView(title: "휴일")
    let availableSeasonView = LabelStackView(title: "이용시기")
    let availableTimeView = LabelStackView(title: "이용시간")
    
    lazy var verticalStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [availableSeasonView, availableTimeView, openDateView, restDateView])
        stack.axis = .vertical
        stack.distribution = .fill
        stack.spacing = 8
        return stack
    }()
    
    func inputData(data: TourPlaceInfo.TimeData){
        
//        guard let data = data else { return }
        
        availableSeasonView.contentLabel.text = data.availableSeason
        availableTimeView.contentLabel.text = data.availableTime
        openDateView.contentLabel.text = data.openDate
        restDateView.contentLabel.text = data.restDate
    }
    
    func checkValidation() {
        var isDisplay = false
        [openDateView, restDateView, availableTimeView, availableSeasonView].forEach { view in
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
        iconImageView.image = UIImage(systemName: "stopwatch.fill")
        titleLabel.text = "시간 안내"
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
