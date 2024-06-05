//
//  Const.swift
//  KoreaTourist
//
//  Created by 의식주컴퍼니 on 6/5/24.
//

import Foundation

struct Constant {
    #if DEV
    static var minimumDiscoveryDistance: Double = 5000
    #else
    static var minimumDiscoveryDistance: Double = 500
    #endif
    
    #if DEV
    static var defaultSearchRadius: Double = 5000
    #else
    static var defaultSearchRadius: Double = 500
    #endif
    
    //
    static var defaultMarkerCaptionTextSize: CGFloat = 16
    static var defaultMarkerSubCaptionTextSize: CGFloat = 14
    static var defaultMarkerImageWidth: CGFloat = 36
    static var defaultMarkerImageHeight: CGFloat {
        Self.defaultMarkerImageWidth * 4 / 3
    }
}
