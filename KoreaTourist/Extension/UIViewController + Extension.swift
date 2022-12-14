//
//  UIViewController + Extension.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2022/12/15.
//

import UIKit

extension UIViewController {
    func showAlert(title: String, message:String = "", actions: [UIAlertAction] = [UIAlertAction(title: "확인", style: .cancel)] ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        actions.forEach { alert.addAction($0) }
        
        present(alert, animated: true)
    }
    
    var isModal: Bool {
            if let index = navigationController?.viewControllers.firstIndex(of: self), index > 0 {
                return false
            } else if presentingViewController != nil {
                return true
            } else if let navigationController = navigationController, navigationController.presentingViewController?.presentedViewController == navigationController {
                return true
            } else if let tabBarController = tabBarController, tabBarController.presentingViewController is UITabBarController {
                return true
            } else {
                return false
            }
        }
}
