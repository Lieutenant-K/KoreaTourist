//
//  Combine + Extension.swift
//  KoreaTourist
//
//  Created by 김윤수 on 10/21/23.
//

import Foundation
import Combine

extension Publisher {
    func withUnretained<T: AnyObject>(_ object: T) -> Publishers.CompactMap<Self, (T, Self.Output)> {
        compactMap { [weak object] output in
            guard let object = object else {
                return nil
            }
            return (object, output)
        }
    }
}
