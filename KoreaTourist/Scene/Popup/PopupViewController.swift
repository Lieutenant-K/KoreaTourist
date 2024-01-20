//
//  MockPopupViewController.swift
//  KoreaTourist
//
//  Created by 김윤수 on 10/19/23.
//

import UIKit
import Combine

import SnapKit
import Then
import Kingfisher
import Hero

final class PopupViewController: UIViewController {
    // MARK: - View
    private let announceLabel = BasePaddingLabel(value: 20).then {
        $0.font = .systemFont(ofSize: 24, weight: .semibold)
        $0.textColor = .label
        $0.textAlignment = .center
        $0.numberOfLines = 1
        $0.lineBreakMode = .byWordWrapping
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 16
        $0.text = "새로운 장소 발견!"
    }
    
    private lazy var announceView = UIView().then {
        let visual = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
        visual.clipsToBounds = true
        visual.layer.cornerRadius = 16
        
        $0.addSubview(visual)
        $0.layer.shadowOffset = CGSize(width: 0, height: 0)
        $0.layer.shadowOpacity = 0.5
        
        visual.snp.makeConstraints { $0.edges.equalToSuperview() }
        visual.contentView.addSubview(self.announceLabel)
        self.announceLabel.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
    
    private let contentView = UIView().then {
        let visual = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
        visual.clipsToBounds = true
        visual.layer.cornerRadius = 16
        
        $0.addSubview(visual)
        visual.snp.makeConstraints { $0.edges.equalToSuperview() }
        $0.layer.cornerRadius = 16
        $0.layer.shadowOffset = CGSize(width: 0, height: 0)
        $0.layer.shadowOpacity = 0.5
    }
    
    private let imageView = UIImageView().then {
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 10
        $0.contentMode = .scaleAspectFill
        $0.tintColor = .secondaryLabel
        $0.kf.indicatorType = .activity
    }
    
    private let titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 24, weight: .semibold)
        $0.textColor = .label
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.lineBreakMode = .byWordWrapping
        $0.lineBreakStrategy = .hangulWordPriority
        $0.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        $0.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }
    
    private let descriptionLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 20, weight: .medium)
        $0.textColor = .secondaryLabel
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.lineBreakMode = .byWordWrapping
        $0.lineBreakStrategy = .hangulWordPriority
    }
    
    private let okButton = UIButton(type: .custom).then {
        $0.setTitle("확인", for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        $0.setTitleColor(.label, for: .normal)
    }
    
    private let detailButton = UIButton(type: .custom).then {
        $0.setTitle("세부정보 보기", for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        $0.setTitleColor(.secondaryLabel, for: .normal)
    }
    
    private lazy var buttonStackView = UIStackView(arrangedSubviews: [self.okButton, self.detailButton]).then {
        $0.axis = .horizontal
        $0.distribution = .fillEqually
        $0.alignment = .fill
    }
    
    // MARK: - Properties
    
    private let viewModel: PopupViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initializer
    
    init(viewModel: PopupViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.modalTransitionStyle = .coverVertical
        self.modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bindViewModel()
        self.configureSubviews()
    }
    
    private func bindViewModel() {
        let input = PopupViewModel.Input(
            viewDidLoadEvent: Just(()).eraseToAnyPublisher(),
            okButtonTapEvent: self.okButton.tapPublisher,
            detailInfoButtonTapEvent: self.detailButton.tapPublisher)
        let output = self.viewModel.transform(input: input, cancellables: &self.cancellables)
        
        output.title
            .sink { [weak self] in
                self?.titleLabel.text = $0
            }
            .store(in: &self.cancellables)
        
        output.description
            .sink { [weak self] in
                self?.descriptionLabel.text = $0
            }
            .store(in: &self.cancellables)

        output.imageURL
            .map { URL(string: $0) }
            .sink { [weak self] in
                self?.imageView.kf.setImage(
                    with: $0,
                    placeholder: UIImage(systemName: "photo")?.applyingSymbolConfiguration(.init(weight: .light)),
                    options: [.transition(.fade(0.5))]
                )
            }
            .store(in: &self.cancellables)
    }
}

extension PopupViewController {
    private func configureSubviews() {
        [self.imageView, self.titleLabel, self.descriptionLabel, self.buttonStackView].forEach {
            self.contentView.addSubview($0)
        }
        
        [self.contentView, self.announceView].forEach {
            self.view.addSubview($0)
        }
        
        self.contentView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(40)
            make.height.equalTo(contentView.snp.width).multipliedBy(1.2)
        }
        
        self.imageView.snp.makeConstraints { make in
            make.top.equalTo(40)
            make.leading.trailing.equalToSuperview().inset(40)
            make.height.equalTo(imageView.snp.width).multipliedBy(2.0 / 3.0)
        }
        
        self.titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.leading.greaterThanOrEqualTo(20)
            make.trailing.lessThanOrEqualTo(-20)
        }
        
        self.descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.leading.greaterThanOrEqualTo(20)
            make.trailing.lessThanOrEqualTo(-20)
            make.bottom.equalTo(buttonStackView.snp.top).offset(-20)
        }
        
        self.buttonStackView.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalToSuperview()
            make.height.equalTo(50)
        }
        
        self.announceView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(contentView)
            make.bottom.equalTo(contentView.snp.top).offset(-12)
            make.height.equalTo(announceLabel.snp.height)
        }
    }
}
