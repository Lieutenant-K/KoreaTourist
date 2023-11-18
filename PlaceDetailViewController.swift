//
//  PlaceDetailViewController.swift
//  KoreaTourist
//
//  Created by 김윤수 on 11/12/23.
//

import UIKit
import Combine
import CombineCocoa

import Then
import SnapKit
import Kingfisher

final class PlaceDetailViewController: UIViewController {
    // MARK: - Views
    private let backgroundImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.backgroundColor = .secondarySystemBackground
    }
    private let imageContainer = UIView().then {
        $0.backgroundColor = .secondarySystemBackground
    }
    private let contentView = UIView().then {
        $0.layer.shadowOffset = CGSize(width: 0, height: 0)
        $0.layer.shadowOpacity = 0.5
        $0.layer.cornerRadius = 10
        $0.backgroundColor = .systemBackground
    }
    private lazy var scrollView = UIScrollView().then {
        $0.addSubview(self.imageContainer)
        $0.addSubview(self.contentView)
        $0.backgroundColor = .systemBackground
        $0.delegate = self
    }
    private let titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 30, weight: .bold)
        $0.numberOfLines = 0
        $0.textAlignment = .center
    }
    private let galleryView = AutoScrollGalleryView()
    private let mapView = DiscoveredPlaceMapView()
    private let tabMenuContainerView = UIView()
    private lazy var topFloatingView = TopFloatingView(superView: self.view, backgroundBlur: .systemUltraThinMaterial)
    
    // MARK: - Properties & Method
    private let tabMenuViewController: PlaceDetailTabMenuViewController
    private let viewModel: PlaceDetailViewModel
    private var cancellables = Set<AnyCancellable>()
    
    init(tabMenuViewController: PlaceDetailTabMenuViewController, viewModel: PlaceDetailViewModel) {
        self.tabMenuViewController = tabMenuViewController
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
    
    deinit {
        self.changeNavigationBarState(isEnabled: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureSubviews()
        self.changeNavigationBarState(isEnabled: false)
        self.addTabMenuViewControllerAsChild()
        self.bindViewModel()
    }
    
    private func bindViewModel() {
        let input = PlaceDetailViewModel.Input(
            viewDidLoadEvent: Just(()).eraseToAnyPublisher(),
            mapViewTabEvent: self.mapView.tapPublisher
        )
        let output = self.viewModel.transform(input: input, cancellables: &self.cancellables)
        
        output.placeInfo
            .compactMap { $0 }
            .withUnretained(self)
            .sink {
                $0.titleLabel.text = $1.title
                $0.configureTopFloatingView(title: $1.title)
                $0.updateBackgroundImage(with: $1.thumbnailImageURL)
                $0.updateMapView(address: $1.address, position: $1.position, discoverDate: $1.discoverDate)
            }
            .store(in: &self.cancellables)
        
        output.placeImages
            .withUnretained(self)
            .sink {
                $0.galleryView.updateImages(with: $1)
            }
            .store(in: &self.cancellables)
    }
}

extension PlaceDetailViewController {
    private func updateBackgroundImage(with url: String) {
        let url = URL(string: url)
        self.backgroundImageView.kf.setImage(with: url, options: [.transition(.fade(0.3))])
    }
    
    private func updateMapView(address: String, position: Coordinate, discoverDate: Date?) {
        self.viewDidAppearPublisher
            .withUnretained(self)
            .sink { object, _ in
                object.mapView.updateAddress(with: address)
                object.mapView.displayMarker(position: position, date: discoverDate)
            }
            .store(in: &self.cancellables)
    }
}

extension PlaceDetailViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let imageContainerHeight = self.imageContainer.frame.height
        let safeAreaTopInset = self.view.safeAreaInsets.top
        let maxOffset = (imageContainerHeight / 2) - 100
        let alpha = (scrollView.contentOffset.y + safeAreaTopInset) / (safeAreaTopInset + maxOffset)
        self.topFloatingView.backgroundAlpha = alpha
    }
    
    private func changeNavigationBarState(isEnabled: Bool) {
        self.navigationController?.navigationBar.standardAppearance = self.clearNaviBarAppearance()
        self.navigationController?.navigationBar.alpha = isEnabled ? 1 : 0
        self.navigationController?.navigationBar.isUserInteractionEnabled = isEnabled
//        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
}

extension PlaceDetailViewController {
    private func configureTopFloatingView(title: String) {
        let titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.text = title
        titleLabel.textColor = .label
        
        self.topFloatingView.titleView = titleLabel
        self.topFloatingView.leftBarItem = self.closeButton()
    }
    
    private func closeButton() -> UIBarButtonItem {
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .heavy)
        let image = UIImage(systemName: "chevron.left")?.applyingSymbolConfiguration(config)
        let closeButton = UIBarButtonItem(image: image, style: .plain, target: nil, action: nil)
        
        closeButton.tintColor = .label
        closeButton.tapPublisher
            .withUnretained(self)
            .sink { object, _ in
                object.handleCloseButtonTapEvent()
            }
            .store(in: &self.cancellables)
        
        return closeButton
    }
    
    private func clearNaviBarAppearance() -> UINavigationBarAppearance {
        let standard = UINavigationBarAppearance()
        standard.configureWithTransparentBackground()
        standard.backgroundColor = .clear
        return standard
    }
    
    private func handleCloseButtonTapEvent() {
        if self.isModal {
            self.dismiss(animated: true)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
}

extension PlaceDetailViewController {
    private func configureSubviews() {
        self.view.addSubview(self.scrollView)
        self.scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        self.imageContainer.addSubview(self.backgroundImageView)
        self.imageContainer.snp.makeConstraints {
            $0.trailing.leading.equalTo(self.scrollView.frameLayoutGuide)
            $0.top.equalTo(self.scrollView.contentLayoutGuide)
            $0.height.equalTo(self.imageContainer.snp.width).multipliedBy(0.75)
        }
        
        self.contentView.snp.makeConstraints {
            $0.top.equalTo(self.imageContainer.snp.centerY).offset(-100)
            $0.leading.trailing.equalTo(self.scrollView.frameLayoutGuide).inset(20)
            $0.bottom.equalTo(self.scrollView.contentLayoutGuide).offset(-50)
            $0.height.greaterThanOrEqualTo(0)
        }
        
        self.backgroundImageView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.top.equalTo(self.view.snp.top).priority(.high)
            $0.height.greaterThanOrEqualTo(self.imageContainer.snp.height)
        }
        
        self.contentView.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints {
            $0.top.equalTo(self.contentView.safeAreaLayoutGuide).offset(20)
            $0.centerX.equalToSuperview()
            $0.leading.greaterThanOrEqualToSuperview().offset(12)
            $0.trailing.lessThanOrEqualToSuperview().offset(-12)
        }
        
        let stackView = UIStackView(arrangedSubviews: [self.mapView, self.galleryView, self.tabMenuContainerView]).then {
            $0.axis = .vertical
            $0.spacing = 20
            $0.alignment = .fill
            $0.distribution = .fill
        }
        self.contentView.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.top.equalTo(self.titleLabel.snp.bottom).offset(20)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private func addTabMenuViewControllerAsChild() {
        let tabMenuView = self.tabMenuViewController.view!
        self.addChild(self.tabMenuViewController)
        self.tabMenuContainerView.addSubview(tabMenuView)
        tabMenuView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        self.tabMenuViewController.didMove(toParent: self)
    }
}
