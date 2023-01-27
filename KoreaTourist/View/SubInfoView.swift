//
//  PlaceInfoTypeView.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2022/11/02.
//

import UIKit

final class SubInfoView: BaseView {
    var buttons = [UIButton]()
    let contentView = UIView()
    let buttonStack = UIStackView(frame: .zero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureButtons()
    }
    
    private func configureButtons() {
        let titles = ["소개", "정보", "안내"]
        
        titles.enumerated().forEach { i, title in
            let button = UIButton(type: .custom)
                button.tag = i
                button.configurationUpdateHandler = createButtonUpdateHandler(title: title)
                buttons.append(button)
                buttonStack.addArrangedSubview(button)
        }
        
        buttonStack.alignment = .fill
        buttonStack.distribution = .fillEqually
        buttonStack.axis = .horizontal
        buttonStack.spacing = 0
    }
    
    private func createButtonUpdateHandler(title: String) -> UIButton.ConfigurationUpdateHandler {
        return { button in
            var color: UIColor
            var font: UIFont
            
            switch button.state {
            case .selected:
                color = .label
                font = .systemFont(ofSize: 18, weight: .semibold)
                button.setBorderLine()
            default:
                color = .secondaryLabel
                font = .systemFont(ofSize: 18, weight: .medium)
                button.setBorderLine()
            }
            
            let container = AttributeContainer([.font:font, .foregroundColor:color])
            let attrTitle = AttributedString(title, attributes: container)
            
            var config = UIButton.Configuration.plain()
            config.attributedTitle = attrTitle
            config.background.cornerRadius = 0
            config.background.backgroundColor = .clear
            
            button.configuration = config
        }
    }

    override func addSubviews() {
        addSubview(buttonStack)
        addSubview(contentView)
    }

    override func addConstraint() {
        buttonStack.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
            $0.height.equalTo(48)
        }
        
        contentView.snp.makeConstraints {
            $0.top.equalTo(buttonStack.snp.bottom)
            $0.leading.bottom.trailing.equalToSuperview()
            $0.height.equalTo(1000)
        }
    }
}
