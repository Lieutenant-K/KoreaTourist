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

final class MapViewController: BaseViewController {
    
    // MARK: - Properties
    
    // 한국관광공사 좌표
    let defaultX = 126.981611
    let defaultY = 37.568477
    
    var naverMapView = MapView()
    
    let locationManager = NMFLocationManager.sharedInstance()!
    
    var currentMarkers = [PlaceMarker]()
    
    var undiscoverdMarkerHandler: NMFOverlayTouchHandler?
    
    var discoveredMarkerHandler: NMFOverlayTouchHandler?
    
    var isMarkerFilterOn = false {
        didSet {
            filteringMarker(isOn: isMarkerFilterOn)
        }
    }
    
    
    // MARK: - LifeCycle
    
    override func loadView() {
        view = naverMapView
        
        naverMapView.mapView.touchDelegate = self
        
        naverMapView.searchButton.addTarget(self, action: #selector(touchSearchPlaceButton), for: .touchUpInside)
        
        naverMapView.circleButton.delegate = self
        
        naverMapView.circleButton.buttonsCount = Menu.allCases.count
        
        
    }
    
    override func configureNavigationItem() {
        
        let appear = UINavigationBarAppearance()
        appear.configureWithTransparentBackground()
        appear.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        
        navigationItem.standardAppearance = appear
        navigationItem.scrollEdgeAppearance = appear
        
        let label = BasePaddingLabel(value: 0)
        label.text = "현재 지역"
        label.font = .systemFont(ofSize: 26, weight: .heavy)
        label.textColor = .secondaryLabel
        
        navigationItem.titleView = label
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.add(self)
        
        realm.printRealmFileURL()
        
        defineMarkerTouchHandler()
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
    
    func defineMarkerTouchHandler() {
        
        undiscoverdMarkerHandler = { [weak self] marker in
            if let marker = marker as? PlaceMarker {
                
                let ok = UIAlertAction(title: "네", style: .cancel) { _ in
                    self?.discoverPlace(about: marker)
                    
                }
                let cancel = UIAlertAction(title: "아니오", style: .default)
                let actions = [cancel, ok]
                
                if marker.distance <= PlaceMarker.minimunDistance {
                    self?.showAlert(title: "이 장소를 발견하시겠어요?", actions: actions)
                } else {
                    self?.showAlert(title: "아직 발견할 수 없어요!", message: "100m 이내로 접근해주세요")
                }
                
                
            }
            return true
        }
        
        discoveredMarkerHandler = { [weak self] marker in
           // 이미 발견된 마커에 대한 핸들러
            return true
        }
        
    }
    
    func filteringMarker(isOn: Bool) {
        
        
        currentMarkers.forEach { $0.hidden = isOn ? ($0.placeInfo.isDiscovered ? true : false) : false }
        
        
    }
    
    func searchNearPlace() {
//        let circle = Circle(x: <#T##Double#>, y: <#T##Double#>, radius: <#T##Int#>)
        APIManager.shared.requestNearPlace(pos: Circle.visitKorea) { [weak self] placeList in
            
            if placeList.count > 0 {
                self?.createPlaceMarkers(placeList: placeList)
                //                self?.updatePlaceMarker(placeList: placeList)
            } else {
                self?.showAlert(title: "500m 이내에 찾을 장소가 없습니다!")
            }
        }
        
    }
    
    private func discoverPlace(about marker: PlaceMarker) {
        
        realm.discoverPlace(with: marker.placeInfo.contentId)
        marker.updateMarkerAppearnce()
        marker.touchHandler = discoveredMarkerHandler
        
        present(PopupViewController(place: marker.placeInfo), animated: true)
        naverMapView.mapView.positionMode = .normal
        locationManager.stopUpdatingLocation()
        
    }
    
    private func createPlaceMarkers(placeList: [CommonPlaceInfo]) {
        
        let newPlace = realm.registPlaces(using: placeList)
        
        let alertTitle = newPlace.newCount > 0 ? "\(newPlace.newCount)개의 새로운 장소를 찾았습니다!" : "새로운 장소를 찾지 못했습니다."
        
        showAlert(title: alertTitle)
//        print(newPlace.newInfoList)
        let markers = newPlace.fetchedInfo.map { (info) -> PlaceMarker in
            let marker = PlaceMarker(place: info)
            marker.touchHandler = info.isDiscovered ? discoveredMarkerHandler : undiscoverdMarkerHandler
            return marker
        }
        
        updatePlaceMarker(markers: markers)
        
    }
    
    private func updatePlaceMarker(markers: [PlaceMarker]) {
        
        currentMarkers.forEach { $0.mapView = nil }
        
        currentMarkers = markers
        
        displayMarkersOnMap(markers: markers)
        
        naverMapView.mapView.positionMode = .normal
        locationManager.startUpdatingLocation()
        
    }
    
    private func displayMarkersOnMap(markers: [PlaceMarker]) {
        
        markers.forEach { $0.mapView = naverMapView.mapView }
        
        let bounds = NMGLatLngBounds(latLngs: markers.map { $0.position } )
        
        let camUpdate = NMFCameraUpdate(fit: bounds, padding: 40)
        camUpdate.animation = .easeOut
        camUpdate.animationDuration = 1
        
        self.naverMapView.mapView.moveCamera(camUpdate) { bool in
            print("업데이트 핸들러 호출!", bool)
        }
        
    }
    
    
    private func updateMarkerDistance(pos: NMGLatLng) {
        
        currentMarkers.forEach { marker in
            
            let dis = marker.position.distance(to: pos)
            marker.distance = dis
            
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

extension MapViewController: NMFMapViewTouchDelegate {
    
    func mapView(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng, point: CGPoint) {
        naverMapView.infoWindow.close()
    }
    
    
}

// MARK: - LocationManagerDelegate

extension MapViewController: NMFLocationManagerDelegate {
    
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


extension MapViewController: CircleMenuDelegate {
    
    func circleMenu(_ circleMenu: CircleMenu, willDisplay button: UIButton, atIndex: Int) {
        let menu = Menu.allCases[atIndex]
        button.setImage(menu.image, for: .normal)
        if menu == .vision && isMarkerFilterOn {
            button.setImage(UIImage(systemName: "eye.slash.fill"), for: .normal)
        }
       
        button.backgroundColor = .white
    }
    
    func circleMenu(_ circleMenu: CircleMenu, buttonDidSelected button: UIButton, atIndex: Int) {
        
        
        circleMenu.isSelected = false
    }
    
    func circleMenu(_ circleMenu: CircleMenu, buttonWillSelected button: UIButton, atIndex: Int) {
        
        print(#function)
        
        let menu = Menu.allCases[atIndex]
        switch menu {
        case .search:
            searchNearPlace()
        case .vision:
            isMarkerFilterOn.toggle()
            break
        case .userInfo:
            break
        }
    }
    
    
}
