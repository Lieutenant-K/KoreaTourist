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
    weak var finishDelegate: FinishDelegate?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start(placeInfo: CommonPlaceInfo) {
        let viewModel = PopupViewModel(placeInfo: placeInfo)
        let viewController = MockPopupViewController(viewModel: viewModel)
        viewModel.coordinator = self
        self.navigationController.present(viewController, animated: true)
    }
    
    func finish() {
        self.navigationController.dismiss(animated: true)
        self.finishDelegate?.finish(coordinator: self)
    }
    
    func pushDetailPlaceInfoScene(place: CommonPlaceInfo) {
//        let sub = SubInfoViewController(place: place)
//        let main = MainInfoViewController(place: place, subInfoVC: sub)
//        let vc = PlaceInfoViewController(place: place, mainInfoVC: main)
        self.navigationController.dismiss(animated: true)
        let useCase = CommonPlaceDetailUseCase(placeInfo: place)
        let viewModel = PlaceDetailTapMenuViewModel(useCase: useCase)
        let viewController = PlaceDetailTabMenuViewController(viewModel: viewModel)
        let navi = UINavigationController(rootViewController: viewController)
        navi.modalPresentationStyle = .fullScreen
        self.navigationController.present(navi, animated: true)
    }
}
