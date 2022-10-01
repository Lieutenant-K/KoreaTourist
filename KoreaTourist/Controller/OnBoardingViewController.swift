//
//  OnBoardingViewController.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2022/10/01.
//

import UIKit
import PaperOnboarding
import Then

final class OnBoardingViewController: BaseViewController {
    
    private let noImage = UIImage()
    
    private let onboarding = PaperOnboarding()
    
    private let button = UIButton(type: .system).then {
        var config = UIButton.Configuration.filled()
        config.cornerStyle = .large
        config.buttonSize = .large
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0)
        
        var container = AttributeContainer()
        container.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        container.foregroundColor = UIColor.discoverdMarker
        
        config.attributedTitle = AttributedString("시작하기", attributes: container)
        
        
        $0.configuration = config
        $0.isHidden = true
        
    }
    
    private lazy var items = [
        OnboardingItemInfo(informationImage: .binoculars,
                           title: "내 주변의 볼만한 장소 찾기",
                           description: "검색 버튼을 눌러서 주변 500m 이내의 숨겨진 장소들을 찾아보세요!",
                           pageIcon: noImage,
                           color: .disabledMarker,
                           titleColor: UIColor.white, descriptionColor: UIColor.white, titleFont: .systemFont(ofSize: 32, weight: .bold), descriptionFont: .systemFont(ofSize: 24, weight: .medium), descriptionLabelPadding: 18),
        
        OnboardingItemInfo(informationImage: .map,
                           title: "장소 발견하기",
                           description: "근처 100m 이내로 접근하면 장소를 발견하고 내 컬렉션에 추가할 수 있어요!",
                           pageIcon: noImage,
                           color: .enabledMarker,
                           titleColor: UIColor.white, descriptionColor: UIColor.white, titleFont: .systemFont(ofSize: 32, weight: .bold), descriptionFont: .systemFont(ofSize: 24, weight: .medium), descriptionLabelPadding: 18),
        
        OnboardingItemInfo(informationImage: UIImage(systemName: "square.grid.2x2")!,
                           title: "발견한 장소 한 눈에 보기",
                           description: "각 지역에 흩어져있는 장소들을 찾고 나만의 컬렉션을 모아보세요!",
                           pageIcon: noImage,
                           color: .discoverdMarker,
                           titleColor: UIColor.white, descriptionColor: UIColor.white, titleFont: .systemFont(ofSize: 32, weight: .bold), descriptionFont: .systemFont(ofSize: 24, weight: .medium), descriptionLabelPadding: 18)
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.tintColor = .white
        
        setupOnboardingView()
        
        setupButton()
    }
    
    private func setupOnboardingView() {
        
        onboarding.delegate = self
        onboarding.dataSource = self
        
        view.addSubview(onboarding)

        onboarding.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
    
    private func setupButton() {
        
        view.addSubview(button)
        
        button.snp.makeConstraints { make in
            make.bottom.equalTo(-100)
            make.leading.trailing.equalToSuperview().inset(30)
            make.height.equalTo(60)
        }
        view.bringSubviewToFront(button)
        
    }

}

extension OnBoardingViewController: PaperOnboardingDelegate, PaperOnboardingDataSource {
    
    func onboardingItemsCount() -> Int {
        items.count
    }
    
    func onboardingItem(at index: Int) -> OnboardingItemInfo {
        items[index]
    }
    
    func onboardingWillTransitonToIndex(_ index: Int) {
        print("will transition to \(index), current : \(onboarding.currentIndex)")
//        print(onboarding.currentIndex)
        button.isHidden = true
        button.alpha = 0

    }
    
    func onboardingDidTransitonToIndex(_ index: Int) {
        print("did transition to \(index), current : \(onboarding.currentIndex)")
        
        if onboarding.currentIndex == 2 && index == 2 {
            button.isHidden = false
            button.alpha = 0
            UIView.animate(withDuration: 0.7, delay: 0, options: [.allowUserInteraction, .curveEaseOut]) { [weak self] in
                self?.button.alpha = 1.0
            } completion: { [weak self] bool in
                self?.button.alpha = 1.0
            }
        }
    }
    
    
}
