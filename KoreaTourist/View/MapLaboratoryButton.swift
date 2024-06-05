//
//  MapLaboratoryButton.swift
//  KoreaTourist
//
//  Created by 의식주컴퍼니 on 6/1/24.
//

import UIKit
import Combine

import CombineCocoa
import NMapsMap

final class MapLaboratoryButton: UIButton {
    private let map: NMFMapView
    private let mapLabViewController = MapLaboratoryViewController()
    private var cancellables = Set<AnyCancellable>()
    weak var viewController: UIViewController?
    
    init(map: NMFMapView) {
        self.map = map
        super.init(frame: .zero)
        self.configureButton()
        self.subscribeEvent()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MapLaboratoryButton {
    private func configureButton() {
        self.backgroundColor = .white
        self.layer.shadowOffset = .zero
        self.layer.shadowOpacity = 0.15
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 25, weight: .semibold)
        self.setImage(UIImage(systemName: "gear")?.applyingSymbolConfiguration(symbolConfig), for: .normal)
    }
    
    private func subscribeEvent() {
        self.tapPublisher
            .filter { [weak self] _ in
                self?.mapLabViewController.presentingViewController == nil
            }
            .withUnretained(self)
            .sink { object, _ in
                object.presentLabViewController()
            }
            .store(in: &self.cancellables)
        
        self.mapLabViewController.minZoomLevel
            .compactMap { Double($0) }
            .sink { [weak self] in
                self?.map.minZoomLevel = $0
            }
            .store(in: &self.cancellables)
        
        self.mapLabViewController.maxZoomLevel
            .compactMap { Double($0) }
            .sink { [weak self] in
                self?.map.maxZoomLevel = $0
            }
            .store(in: &self.cancellables)
        
        self.mapLabViewController.lightness
            .compactMap { Double($0) }
            .sink { [weak self] in
                self?.map.lightness = $0
            }
            .store(in: &self.cancellables)
        
        self.mapLabViewController.symbolScale
            .compactMap { Double($0) }
            .sink { [weak self] in
                self?.map.symbolScale = $0
            }
            .store(in: &self.cancellables)
    }
    
    private func presentLabViewController() {
        let viewControllerToPresent = self.mapLabViewController
            if let sheet = viewControllerToPresent.sheetPresentationController {
                sheet.detents = [.medium(), .large()]
                sheet.largestUndimmedDetentIdentifier = .medium
                sheet.prefersScrollingExpandsWhenScrolledToEdge = false
                sheet.prefersEdgeAttachedInCompactHeight = true
                sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
            }
        self.viewController?.present(viewControllerToPresent, animated: true, completion: nil)
    }
}
