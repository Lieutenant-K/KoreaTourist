//
//  LocationServiceManager.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2023/05/22.
//

import Foundation
import CoreLocation
import Combine

final class LocationManager: NSObject {
    private let service = CLLocationManager()
    let locationPublisher = PassthroughSubject<CLLocation, Never>()
    let headingPublisher = PassthroughSubject<CLHeading, Never>()
    let isAuthorized = PassthroughSubject<Bool, Never>()
    
    override init() {
        super.init()
        self.service.delegate = self
        self.service.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func startUpdatingLocation() {
        self.service.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        self.service.stopUpdatingLocation()
    }
    
    func startUpdatingHeading() {
        self.service.startUpdatingHeading()
    }
    
    func stopUpdatingHeading() {
        self.service.stopUpdatingHeading()
    }
    
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            self.locationPublisher.send(location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        self.headingPublisher.send(newHeading)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            self.isAuthorized.send(true)
            self.service.startUpdatingLocation()
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            self.isAuthorized.send(false)
        @unknown default:
            print("정의되지 않은 상태")
        }
    }
}
