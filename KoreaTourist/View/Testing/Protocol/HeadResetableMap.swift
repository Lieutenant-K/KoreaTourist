//
//  CameraHeadResetable.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2023/08/19.
//

import Foundation

import NMapsMap

/// 카메라의 헤딩을 초기화할 수 있는 지도 객체
protocol HeadResetableMap: NMFMapView {
    func resetHeading()
}
