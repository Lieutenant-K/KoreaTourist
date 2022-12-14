//
//  UIAlertAction + Extension.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2022/12/15.
//

import UIKit
extension UIAlertAction {
    static let goSettingAction = UIAlertAction(title: "설정으로 이동", style: .default) { _ in
            if let settingURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingURL)
            }
        }
}
