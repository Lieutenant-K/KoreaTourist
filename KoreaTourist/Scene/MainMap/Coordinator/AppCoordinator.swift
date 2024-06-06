//
//  AppCoordinator.swift
//  KoreaTourist
//
//  Created by 김윤수 on 10/12/23.
//

import UIKit

final class AppCoordinator: Coordinator {
    let navigationController = UINavigationController()
    var childCoordinators: [Coordinator] = []
    private let window: UIWindow?
    
    init(_ window: UIWindow?) {
        self.window = window
        self.navigationController.isNavigationBarHidden = true
    }
    
    func start() {
        let notFirst = UserDefaults.standard.bool(forKey: "notFirst")
        self.window?.rootViewController = self.navigationController
        self.window?.makeKeyAndVisible()
        
        if notFirst {
            self.pushMainMapScene()
        } else {
            self.pushOnboardingScene()
            UserDefaults.standard.set(true, forKey: "notFirst")
        }
    }
    
    func pushMainMapScene() {
        let coordinator = MainMapCoordinator(navigationController: self.navigationController)
        self.childCoordinators.append(coordinator)
        coordinator.start()
    }
    
    func pushOnboardingScene() {
        let viewController = OnBoardingViewController()
        viewController.coordinator = self
        self.navigationController.pushViewController(viewController, animated: true)
    }
}

extension AppCoordinator: OnboardingFinishDelegate {
    func finishOnboardingFlow() {
        self.navigationController.viewControllers = []
        self.pushMainMapScene()
    }
}
