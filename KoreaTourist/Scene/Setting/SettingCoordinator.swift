//
//  SettingCoordinator.swift
//  KoreaTourist
//
//  Created by 김윤수 on 1/18/24.
//

import UIKit
import AcknowList
import SafariServices

final class SettingCoordinator: Coordinator {
    let navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    weak var finishDelegate: FinishDelegate?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewModel = SettingViewModel()
        viewModel.coordinator = self
        let viewController = MockSettingViewController(viewModel: viewModel)
        self.navigationController.pushViewController(viewController, animated: true)
    }
    
    func finish() {
        self.finishDelegate?.finish(coordinator: self)
    }
    
    func pushOpenSourceListScene() {
        let viewController = AcknowListViewController()
        viewController.headerText = "목록"
        viewController.title = "오픈소스 라이브러리"
        self.navigationController.pushViewController(viewController, animated: true)
    }
    
    func presentPrivacyWebPageScene() {
        let url = URL(string: "https://lietenant-k.tistory.com/100")!
        let viewController = SFSafariViewController(url: url)
        self.navigationController.present(viewController, animated: true)
    }
    
    func presentMailScene(viewController: UIViewController) {
        self.navigationController.present(viewController, animated: true)
    }
}
