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
    var tapPublisher: AnyPublisher<UITapGestureRecognizer, Never> {
        self.tapGesture.tapPublisher
    }
    
    init() {
        super.init(frame: .zero)
        self.gestureRecognizers = [self.tapGesture]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
