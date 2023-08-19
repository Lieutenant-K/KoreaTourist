//
//  CompassView.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2023/05/22.
//

import UIKit
import Combine
import CombineCocoa

import NMapsMap

final class CompassView: NMFCompassView {
    private let tapGesture = UITapGestureRecognizer()
    private var cancellables = Set<AnyCancellable>()
    private let map: HeadResetableMap
    override var mapView: NMFMapView? {
        get { self.map }
        set { super.mapView = newValue }
    }
    
    init(map: HeadResetableMap) {
        self.map = map
        super.init(frame: .zero)
        self.mapView = map
        self.gestureRecognizers = [self.tapGesture]
        self.subscribeTapEvent()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func subscribeTapEvent() {
        self.tapGesture.tapPublisher
            .sink { [weak self] _ in
                self?.map.resetHeading()
            }
            .store(in: &self.cancellables)
    }
}
