//
//  MapCameraMod.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2023/08/19.
//

import Foundation

enum MapCameraMode {
    case navigation
    case search
    case select(Coordinate)
}

extension MapCameraMode {
    struct Configuration {
        enum ValueType {
            case min, max, custom(Double)
        }
        enum CoordinateType {
            case userLocation, custom(Coordinate)
        }
        
        let coordinate: CoordinateType
        let tilt: ValueType
        let zoom: ValueType
    }

    
    var config: Configuration {
        switch self {
        case .navigation:
            Configuration(coordinate: .userLocation, tilt: .max, zoom: .max)
        case .search:
            Configuration(coordinate: .userLocation, tilt: .min, zoom: .min)
        case let .select(coordinate):
            Configuration(coordinate: .custom(coordinate), tilt: .max, zoom: .max)
        }
    }
}

extension MapCameraMode {
    enum InsetType {
        case none, `default`
    }
    
    var inset: InsetType {
        switch self {
        case .navigation:
            return .default
        default:
            return .none
        }
    }
}

extension MapCameraMode: Equatable {
    static func == (lhs: MapCameraMode, rhs: MapCameraMode) -> Bool {
        switch (lhs, rhs) {
        case (.navigation, .navigation), (.search, .search):
            return true
        case let (.select(pos1), .select(pos2)):
            return pos1 == pos2
        default:
            return false
        }
    }
}
