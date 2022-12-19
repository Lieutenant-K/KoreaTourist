//
//  CameraMode.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2022/12/20.
//

import UIKit
import NMapsMap

enum CameraMode: Equatable {
    case navigate
    case search
    case select(NMGLatLng)
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.navigate, .navigate),
            (.search, .search):
            return true
        case (.select(let lpos), .select(let rpos)):
            return lpos == rpos
        default:
            return false
        }
    }
}

extension CameraMode {
    var iconImage: UIImage? {
        switch self {
        case .navigate:
            return UIImage(systemName: "location.fill")
        case .search:
            return UIImage(systemName: "map.fill")
        case .select:
            return nil
        }
    }
    
    var isCenterd: Bool {
        switch self {
        case .navigate:
            return false
        default:
            return true
        }
    }
    
    var isClosed: Bool {
        switch self {
        case .search:
            return false
        default:
            return true
        }
    }
    
    var position: NMGLatLng? {
        switch self {
        case .select(let loc):
            return loc
        default:
            guard let loc = MapViewController.locationManager.location?.coordinate else { return nil}
            return NMGLatLng(from: loc)
        }
    }
}
