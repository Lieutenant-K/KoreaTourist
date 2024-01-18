//
//  MyCollectionCoordinator.swift
//  KoreaTourist
//
//  Created by 김윤수 on 1/4/24.
//

import UIKit

final class MyCollectionCoordinator: Coordinator {
    let navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    private var ownNavigationController: UINavigationController?
    weak var finishDelegate: PopupFinishDelegate?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let useCase = CommonMyCollectionUseCase()
        let viewModel = MyCollectionViewModel(useCase: useCase)
        viewModel.coordinator = self
        let viewController = MyCollectionViewController(viewModel: viewModel)
        let navi = UINavigationController(rootViewController: viewController)
        navi.modalPresentationStyle = .fullScreen
        navi.modalTransitionStyle = .coverVertical
        navi.navigationBar.prefersLargeTitles = true
        navi.view.backgroundColor = .systemBackground
        
        self.ownNavigationController = navi
        self.navigationController.present(navi, animated: true)
    }
    
    func finish() {
        self.navigationController.dismiss(animated: true)
        self.finishDelegate?.finish(coordinator: self)
    }
}

extension MyCollectionCoordinator: PopupFinishDelegate {
    func pushPlaceDetailScene(place: CommonPlaceInfo) {
        if let navigationController = self.ownNavigationController {
            let coordinator = PlaceDetailCoordinator(navigationController: navigationController)
            self.childCoordinators.append(coordinator)
            coordinator.finishDelegate = self
            coordinator.start(placeInfo: place, isModal: false)
        }
    }
    
    func finish(coordinator: Coordinator) {
        if let index = self.childCoordinators.firstIndex(where: { $0 === coordinator }) {
            self.childCoordinators.remove(at: index)
        }
    }
}

extension MyCollectionCoordinator {
    func pushSettingScene() {
        if let navigationController = self.ownNavigationController {
            let coordinator = SettingCoordinator(navigationController: navigationController)
            self.childCoordinators.append(coordinator)
            coordinator.finishDelegate = self
            coordinator.start()
        }
    }
}
