//
//  Combine + Extension.swift
//  KoreaTourist
//
//  Created by 김윤수 on 10/21/23.
//

import UIKit
import Combine
import CombineInterception

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

extension UIViewController {
    var viewDidLoadPublisher: AnyPublisher<Void, Never> {
        let selector = #selector(UIViewController.viewDidLoad)
        return publisher(for: selector)
            .map { _ in () }
            .eraseToAnyPublisher()
    }
    
    var viewWillAppearPublisher: AnyPublisher<Bool, Never> {
        let selector = #selector(UIViewController.viewWillAppear(_:))
        return intercept(selector)
            .map { $0[0] as? Bool ?? false }
            .eraseToAnyPublisher()
    }
    
    var viewDidAppearPublisher: AnyPublisher<Void, Never> {
        let selector = #selector(UIViewController.viewDidAppear(_:))
        return publisher(for: selector)
            .map { _ in }
            .eraseToAnyPublisher()
    }
}
