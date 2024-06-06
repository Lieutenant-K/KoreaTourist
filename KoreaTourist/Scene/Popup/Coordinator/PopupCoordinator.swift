//
//  PopupCoordinator.swift
//  KoreaTourist
//
//  Created by 김윤수 on 10/20/23.
//

import UIKit

final class PopupCoordinator: Coordinator {
    let navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    weak var finishDelegate: PopupFinishDelegate?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start(placeInfo: CommonPlaceInfo) {
        let viewModel = PopupViewModel(placeInfo: placeInfo)
        let viewController = PopupViewController(viewModel: viewModel)
        viewModel.coordinator = self
        self.navigationController.present(viewController, animated: true)
    }
    
    func finish() {
        self.navigationController.dismiss(animated: true)
        self.finishDelegate?.finish(coordinator: self)
    }
    
    func startPlaceDetailScene(place: CommonPlaceInfo) {
        self.finish()
        self.finishDelegate?.pushPlaceDetailScene(place: place)
    }
}
