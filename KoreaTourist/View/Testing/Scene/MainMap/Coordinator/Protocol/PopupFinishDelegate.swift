//
//  PopupFinishDelegate.swift
//  KoreaTourist
//
//  Created by 의식주컴퍼니 on 11/18/23.
//

import Foundation

protocol PopupFinishDelegate: Coordinator {
    func finish(coordinator: Coordinator)
    func pushPlaceDetailScene(place: CommonPlaceInfo)
}
