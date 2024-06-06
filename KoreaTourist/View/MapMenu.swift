//
//  CircleMenu.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2023/05/23.
//

import UIKit

enum MapMenu: Int, CaseIterable {
    case search = 0
    case vision
    case userInfo
    
    private var systemImageName: String {
        switch self {
        case .search:
            return "magnifyingglass"
        case .vision:
            return "eye.fill"
        case .userInfo:
            return "person.fill"
        }
    }
    
    var image: UIImage? {
        UIImage(systemName: self.systemImageName)
    }
}
