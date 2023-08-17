//
//  LocalizedTitleLabel.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2023/05/20.
//

import UIKit

final class LocalizedTitleLabel: UILabel {
    func configure() {
        self.text = "현재 지역"
        self.font = .systemFont(ofSize: 26, weight: .heavy)
        self.textColor = .secondaryLabel
        self.backgroundColor = .clear
        self.textAlignment = .center
        self.numberOfLines = 1
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
