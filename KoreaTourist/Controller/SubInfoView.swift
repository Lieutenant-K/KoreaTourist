//
//  PlaceInfoTypeView.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2022/11/02.
//

import UIKit
import Then

class SubInfoView: BaseView {
    
    var buttons = [UIButton]()
    
    let contentView = UIView()
    
    lazy var buttonStack = UIStackView(arrangedSubviews: []).then {
        $0.alignment = .fill
        $0.distribution = .fillEqually
        $0.axis = .horizontal
        $0.spacing = 0
    }
    
    
    private func configureButtons() {
        
        let titles = ["소개", "정보", "안내"]
        
        for i in 0..<titles.count {
            
            let updateHandler: UIButton.ConfigurationUpdateHandler = { button in
                
                var color: UIColor
                var font: UIFont
                
                switch button.state {
                    
                case .selected:
                    color = .label
                    font = .systemFont(ofSize: 20, weight: .semibold)
                    button.setBorderLine()
                    
                default:
                    color = .secondaryLabel
                    font = .systemFont(ofSize: 20, weight: .medium)
                    button.setBorderLine()
                }
                
                
                let container = AttributeContainer([.font:font, .foregroundColor:color])
                let attrTitle = AttributedString(button.currentTitle!, attributes: container)
                
                var config = UIButton.Configuration.plain()
                config.attributedTitle = attrTitle
                config.background.cornerRadius = 0
                config.background.backgroundColor = .clear
                
                button.configuration = config
                
            }
            
            
            
            let button = UIButton(type: .custom).then {
                $0.setTitle(titles[i], for: .normal)
                $0.tag = i
                $0.configurationUpdateHandler = updateHandler
                buttons.append($0)
                buttonStack.addArrangedSubview($0)
            }
            
        }
        
    }

    override func addSubviews() {
        addSubview(buttonStack)
        addSubview(contentView)
    }

    override func addConstraint() {
        
        buttonStack.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview()
            make.height.equalTo(60)
        }
        
        contentView.snp.makeConstraints { make in
            make.top.equalTo(buttonStack.snp.bottom)
            make.leading.bottom.trailing.equalToSuperview()
            make.height.equalTo(1000)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureButtons()
    }
    
}
