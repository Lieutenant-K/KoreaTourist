//
//  Coordinator.swift
//  KoreaTourist
//
//  Created by 김윤수 on 10/12/23.
//

import UIKit

protocol Coordinator {
    var navigationController: UINavigationController { get }
    var childCoordinators: [Coordinator] { get }
    func start()
}
