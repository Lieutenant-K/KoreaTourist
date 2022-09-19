//
//  ViewController.swift
//  KakaoMap
//
//  Created by 김윤수 on 2022/09/09.
//

import UIKit
import NMapsMap
import SnapKit
import Alamofire
import CircleMenu

enum Menu: CaseIterable {
    
    case search
    case vision
    case userInfo
    
    var image: UIImage? {
        switch self {
        case .search:
            return UIImage(systemName: "magnifyingglass")
        case .vision:
            return UIImage(systemName: "eye.fill")
        case .userInfo:
            return UIImage(systemName: "person.fill")
        }
    }
    
}

class ViewController: UIViewController {
    
    // MARK: - Properties
    
    // 한국관광공사 좌표
    let defaultX = 126.981611
    let defaultY = 37.568477
    
    var naverMapView = MapView()
    
    let locationManager = NMFLocationManager.sharedInstance()!
    
    var currentMarkers = [NMFMarker]()
    
    lazy var markerTouchHandler: NMFOverlayTouchHandler = { [weak self] marker in
        if let marker = marker as? PlaceMarker {
            
            let ok = UIAlertAction(title: "네", style: .cancel) { _ in
                self?.present(PopupViewController(place: marker.placeInfo), animated: true)
                self?.naverMapView.mapView.positionMode = .normal
                self?.locationManager.stopUpdatingLocation()
//                self?.showAlertView()
                
            }
            let cancel = UIAlertAction(title: "아니오", style: .default)
            let actions = [cancel, ok]
            
            if marker.distance <= 100 {
                self?.showAlert(title: "이 장소를 발견하시겠어요?", actions: actions)
            } else {
                self?.showAlert(title: "아직 발견할 수 없어요!", message: "100m 이내로 접근해주세요")
            }
            
            
        }
        return true
    }
    
    // MARK: - LifeCycle
    
    override func loadView() {
        view = naverMapView
        
        naverMapView.mapView.touchDelegate = self
        
        naverMapView.searchButton.addTarget(self, action: #selector(touchSearchPlaceButton), for: .touchUpInside)
        
        naverMapView.circleButton.delegate = self
        
        naverMapView.circleButton.buttonsCount = Menu.allCases.count
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.add(self)
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print(#function)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print(#function)

        
    }
    
    // MARK: - Method
    

    func displayMarkers(markers: [PlaceMarker]) {
        
        markers.forEach { $0.mapView = naverMapView.mapView }
        
        let bounds = NMGLatLngBounds(latLngs: markers.map { $0.position } )
        
        let camUpdate = NMFCameraUpdate(fit: bounds, padding: 40)
        camUpdate.animation = .easeOut
        camUpdate.animationDuration = 1
        
        self.naverMapView.mapView.moveCamera(camUpdate) { bool in
            print("업데이트 핸들러 호출!", bool)
        }
        
    }
    
    func searchNearPlace() {
        
        APIManager.shared.requestNearPlace(pos: Circle.home) { [weak self] data in
            
            if data.count == 0 { return }
            
            let markers = data.map { PlaceMarker(place: $0, touchHandler: self?.markerTouchHandler) }
            
            DispatchQueue.main.async {
                
                self?.currentMarkers.forEach { $0.mapView = nil }
                
                self?.currentMarkers = markers
                
                self?.displayMarkers(markers: markers)
                
                self?.naverMapView.mapView.positionMode = .normal
                self?.locationManager.startUpdatingLocation()
                
            }
        }
        
    }
    
    func updateMarkerDistance(pos: NMGLatLng) {
     
        currentMarkers.forEach { marker in
            if let marker = marker as? PlaceMarker {
                let dis = marker.position.distance(to: pos)
                marker.distance = dis
            }
        }
        
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        let style = UITraitCollection.current.userInterfaceStyle
        naverMapView.mapView.adjustInterfaceStyle(style: style)
    }
    
    // MARK: - Action Method
   
    
    @objc func touchSearchPlaceButton() {
        
        let infoWindowData = NMFInfoWindowDefaultTextSource.data()
//        let infoWindowData = InfoWindowButton()
        naverMapView.infoWindow.dataSource = infoWindowData
        
        searchNearPlace()
    }
    
    
}

// MARK: - MapViewTouchDelegate

extension ViewController: NMFMapViewTouchDelegate {
    
    func mapView(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng, point: CGPoint) {
        naverMapView.infoWindow.close()
    }
    
    
}

// MARK: - LocationManagerDelegate

extension ViewController: NMFLocationManagerDelegate {
    
    func checkAuthorization(auth: CLAuthorizationStatus) {
        
        switch auth {
        case .notDetermined:
            print("not determined")
            CLLocationManager().requestWhenInUseAuthorization()
        case .restricted:
            print("restricted")
        case .denied:
            print("denied", "위치 서비스를 켜주세요 ㅜㅜ")
            // 설정으로 안내하는 코드
        case .authorizedAlways:
            print("always authorized")
        case .authorizedWhenInUse:
            print("authorized when in use")
            CLLocationManager().requestAlwaysAuthorization()
        default:
            print("default")
        }
        
    }
    
    func locationManager(_ locationManager: NMFLocationManager!, didChangeAuthStatus status: CLAuthorizationStatus) {
        print("ChangeAuthStatus")
        
        checkAuthorization(auth: status)

        
    }
    
    func locationManager(_ locationManager: NMFLocationManager!, didUpdateLocations locations: [Any]!) {
        
        let location = NMGLatLng(from: (locations.last as! CLLocation).coordinate)
        
        print("UpdateLocation", location.lat, location.lng)
        
        updateMarkerDistance(pos: location)

    }
    /*
    func locationManagerBackgroundLocationUpdatesDidTimeout(_ locationManager: NMFLocationManager!) {
        print(#function)
    }
    
    func locationManagerBackgroundLocationUpdatesDidAutomaticallyPause(_ locationManager: NMFLocationManager!) {
        print(#function)
    }
    */
    
    func locationManagerDidStartLocationUpdates(_ locationManager: NMFLocationManager!) {
        print("StartLocationUpdates")
        
    }
    
    func locationManagerDidStopLocationUpdates(_ locationManager: NMFLocationManager!) {
        print("StopLocationUpdates")
        
    }
    
}


extension ViewController: CircleMenuDelegate {
    
    func circleMenu(_ circleMenu: CircleMenu, willDisplay button: UIButton, atIndex: Int) {
        let menu = Menu.allCases[atIndex]
        button.setImage(menu.image, for: .normal)
        button.backgroundColor = .systemBackground
    }
    
    func circleMenu(_ circleMenu: CircleMenu, buttonDidSelected button: UIButton, atIndex: Int) {
        print(#function)
        
        let menu = Menu.allCases[atIndex]
        switch menu {
        case .search:
            searchNearPlace()
        case .vision:
            break
        case .userInfo:
            break
        }
        
        circleMenu.isSelected = false
    }
    
    
}
