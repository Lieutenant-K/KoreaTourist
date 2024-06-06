//
//  PlaceDetailCoordinator.swift
//  KoreaTourist
//
//  Created by 의식주컴퍼니 on 11/18/23.
//

import UIKit

import Hero

final class PlaceDetailCoordinator: Coordinator {
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    weak var finishDelegate: FinishDelegate? // 임시 델리게이트
    private var ownNavigationController: UINavigationController?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func finish() {
        self.navigationController.dismiss(animated: true)
        self.finishDelegate?.finish(coordinator: self)
    }
    
    func start(placeInfo: CommonPlaceInfo, isModal: Bool) {
        let useCase = CommonPlaceDetailUseCase(placeInfo: placeInfo)
        let tabMenuViewModel = PlaceDetailTabMenuViewModel(useCase: useCase)
        let tabMenuViewController = PlaceDetailTabMenuViewController(viewModel: tabMenuViewModel)
        let viewModel = PlaceDetailViewModel(useCase: useCase)
        viewModel.coordinator = self
        let viewController = PlaceDetailViewController(tabMenuViewController: tabMenuViewController, viewModel: viewModel)
        
        let navi = UINavigationController(rootViewController: viewController)
        navi.modalPresentationStyle = .fullScreen
        navi.isHeroEnabled = true
        
        if isModal {
            navi.heroModalAnimationType = .selectBy(presenting: .zoom, dismissing: .zoomOut)
        } else {
            navi.heroModalAnimationType = .autoReverse(presenting: .push(direction: .left))
        }
        
        self.navigationController.present(navi, animated: true)
        self.ownNavigationController = navi
    }
}

extension PlaceDetailCoordinator {
    func presentDiscoverdMapScene(place: CommonPlaceInfo) {
        let viewController = DiscoveredPlaceMapViewController(placeInfo: place)
        viewController.modalPresentationStyle = .fullScreen
        viewController.isHeroEnabled = true
        self.ownNavigationController?.present(viewController, animated: true)
    }
}
