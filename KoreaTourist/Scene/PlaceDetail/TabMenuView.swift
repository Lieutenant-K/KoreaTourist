//
//  TabMenuView.swift
//  KoreaTourist
//
//  Created by 김윤수 on 12/16/23.
//

import UIKit
import Combine

import Then
import SnapKit

final class TabMenuView: UIView {
    private var buttons: [UIButton] = []
    private let stackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fillEqually
        $0.alignment = .center
    }
    private let bottomSeparatorLine = UIView().then {
        $0.backgroundColor = .separator
    }
    private let selectBar = UIView().then {
        $0.backgroundColor = .black
        $0.isHidden = true
    }
    
    private var cancellables = Set<AnyCancellable>()
    private let selectedButtonSubject = PassthroughSubject<Int, Never>()
    var selectedButtonPublisher: AnyPublisher<Int, Never> {
        self.selectedButtonSubject.eraseToAnyPublisher()
    }
    
    init(buttonTitles: [String] = []) {
        super.init(frame: .zero)
        self.configureSubviews()
        self.addButtonWithTitle(buttonTitles)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addButtonWithTitle(_ titles: [String]) {
        titles.forEach { title in
            let button = UIButton(type: .custom)
            button.tag = self.buttons.count
            
            self.configureButtonAppearanceForState(button, title: title)
            self.subscribeButtonEvent(button)
            self.stackView.addArrangedSubview(button)
            self.buttons.append(button)
        }
        
        // 버튼 추가 후 가장 첫번째 버튼을 탭
        if self.buttons.count > 0 {
            self.buttons[0].sendActions(for: .touchUpInside)
        }
    }
    
    private func configureButtonAppearanceForState(_ button: UIButton, title: String) {
        let normalAttributes: [NSAttributedString.Key: Any]  = [.font: UIFont.systemFont(ofSize: 18, weight: .medium),
                                .foregroundColor: UIColor.secondaryLabel]
        let selectedAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 18, weight: .semibold),
                                  .foregroundColor: UIColor.label]
        
        button.setAttributedTitle(NSAttributedString(string: title, attributes: normalAttributes), for: .normal)
        button.setAttributedTitle(NSAttributedString(string: title, attributes: selectedAttributes), for: .selected)
    }
    
    private func subscribeButtonEvent(_ button: UIButton) {
        button.tapPublisher
            .map { button.tag }
            .withUnretained(self)
            .sink { object, tag in
                object.selectButtonOnly(with: tag)
                object.moveSelectBarToButton(with: tag)
                object.selectedButtonSubject.send(tag)
                object.selectBar.isHidden = false
            }
            .store(in: &self.cancellables)
    }
}

extension TabMenuView {
    private func moveSelectBarToButton(with tag: Int) {
        if self.buttons.indices.contains(tag) {
            let selectedButton = self.buttons[tag]
            
            self.selectBar.snp.remakeConstraints {
                $0.bottom.equalTo(self.bottomSeparatorLine)
                $0.horizontalEdges.equalTo(selectedButton)
                $0.height.equalTo(2)
            }
            
            UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseOut]) {
                self.layoutIfNeeded()
            }
        }
    }
    
    private func selectButtonOnly(with tag: Int) {
        self.buttons.forEach {
            $0.isSelected = $0.tag == tag
        }
    }
}

extension TabMenuView {
    private func configureSubviews() {
        self.addSubview(self.stackView)
        self.addSubview(self.bottomSeparatorLine)
        self.addSubview(self.selectBar)
        
        self.stackView.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
        }
        
        self.bottomSeparatorLine.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        self.selectBar.snp.makeConstraints {
            $0.bottom.equalTo(self.bottomSeparatorLine)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(2)
        }
    }
}
