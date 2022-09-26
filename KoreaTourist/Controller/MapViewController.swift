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
import SideMenu


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

enum CameraMode: Equatable {
    
    case navigate
    case search
    case select(NMGLatLng)
    
    var iconImage: UIImage? {
        switch self {
        case .navigate:
            return UIImage(systemName: "location.fill")
        case .search:
            return UIImage(systemName: "map.fill")
        case .select:
            return nil
        }
    }
    
    var isCenterd: Bool {
        switch self {
        case .navigate:
            return false
        default:
            return true
        }
    }
    
    var isClosed: Bool {
        switch self {
        case .search:
            return false
        default:
            return true
        }
    }
    
    var position: NMGLatLng? {
        switch self {
        case .select(let loc):
            return loc
        default:
            guard let loc = CLLocationManager().location?.coordinate else { return nil}
            return NMGLatLng(from: loc)
        }
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
            switch (lhs, rhs) {
            case (.navigate, .navigate),
                 (.search, .search):
                return true
            case (.select(let lpos), .select(let rpos)):
                return lpos == rpos
            default:
                return false
            }
        }
    
}

final class MapViewController: BaseViewController {
    
    // MARK: - Properties
    
    // 한국관광공사 좌표
    let defaultX = 126.981611
    let defaultY = 37.568477

    var naverMapView = MapView()
    
    let locationManager = NMFLocationManager()
    
    var currentMarkers = [PlaceMarker]()
    
    var markerHandler: NMFOverlayTouchHandler?
    
    var isMarkerFilterOn = false {
        didSet {
            filteringMarker()
        }
    }
    
    var cameraMode: CameraMode = .navigate {
        willSet {
            switch newValue {
            case .navigate:
                previousMode = previousMode != nil ? .search : nil
            case .search:
                previousMode = .navigate
            case .select(_):
                if cameraMode == .search || cameraMode == .navigate {
                    previousMode = cameraMode
                }
            }
        }
        didSet { updateCameraFrom(mode: cameraMode) }
    }
    
    var previousMode: CameraMode? {
        didSet {
            if let pre = previousMode {
                naverMapView.cameraButton.isHidden = false
                naverMapView.cameraButton.setImage(pre.iconImage, for: .normal)
            } else {
                naverMapView.cameraButton.isHidden = true
            }
        }
    }
    
    
    // MARK: - LifeCycle
    
    override func loadView() {
        view = naverMapView
        
        naverMapView.panGesture.addTarget(self, action: #selector(panning(_:)))
        
        naverMapView.pinchGesture.addTarget(self, action: #selector(pinch(_:)))
        
        naverMapView.cameraButton.addTarget(self, action: #selector(touchPreviousCameraButton), for: .touchUpInside)
        
        naverMapView.menuButton.addTarget(self, action: #selector(touchMenuButton), for: .touchUpInside)
        
        naverMapView.mapView.touchDelegate = self
        
        naverMapView.circleButton.delegate = self
        
        naverMapView.circleButton.buttonsCount = Menu.allCases.count
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(#function)
        
        locationManager.add(self)
        
        realm.printRealmFileURL()
        
        settingMarkerTouchHandler()
        
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
    
    override func configureNavigationItem() {
        /*
        let appear = UINavigationBarAppearance()
        appear.configureWithTransparentBackground()
//        appear.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        
        navigationItem.standardAppearance = appear
        navigationItem.scrollEdgeAppearance = appear
        
        let label = BasePaddingLabel(value: 0)
        label.text = "현재 지역"
        label.font = .systemFont(ofSize: 26, weight: .heavy)
        label.textColor = .secondaryLabel
        
        navigationItem.titleView = label
        */
        
    }
    
    func settingMarkerTouchHandler() {
        
        markerHandler = { [weak self] marker in
            if let marker = marker as? PlaceMarker {
                
                if self?.cameraMode == .select(marker.position) {
                    self?.showDiscoverAlert(target: marker)
                } else {
                    self?.cameraMode = .select(marker.position)
                }
                
            }
            return true
        }
        
    }
    
    private func showDiscoverAlert(target marker: PlaceMarker) {
        
        if marker.placeInfo.isDiscovered {
            print("이미 발견됨!!!!")
            return
        }
        
        let ok = UIAlertAction(title: "네", style: .cancel) { [weak self] _ in
            self?.discoverPlace(about: marker)
        }
        
        let cancel = UIAlertAction(title: "아니오", style: .default)
        
        let actions = [cancel, ok]
        
        if marker.distance <= PlaceMarker.minimumDistance {
            showAlert(title: "이 장소를 발견하시겠어요?", actions: actions)
        } else {
            showAlert(title: "아직 발견할 수 없어요!", message: "\(Int(PlaceMarker.minimumDistance))m 이내로 접근해주세요")
        }
        
    }
    
    private func discoverPlace(about marker: PlaceMarker) {
        
        realm.discoverPlace(with: marker.placeInfo.contentId)
        marker.updateMarkerAppearnce()
        
        present(PopupViewController(place: marker.placeInfo), animated: true)
//        naverMapView.mapView.positionMode = .normal
//        locationManager.stopUpdatingLocation()
        
    }
    
    func filteringMarker() {
        
        currentMarkers.forEach { $0.hidden = isMarkerFilterOn ? ($0.placeInfo.isDiscovered ? true : false) : false }
        
    }
    
    func searchNearPlace() {

        APIManager.shared.requestNearPlace(pos: Circle.visitKorea) { [weak self] placeList in
            
            if placeList.count > 0 {
                if let markers = self?.createPlaceMarkers(placeList: placeList) {
                    self?.updateAndDisplayMarker(markers: markers)
                    self?.cameraMode = .search
                }
            } else {
                self?.showAlert(title: "\(Int(Circle.defaultRadius)) 이내에 찾을 장소가 없습니다!")
            }
            
            self?.displayAreaOnMap()
        }
        
    }
    
    private func createPlaceMarkers(placeList: [CommonPlaceInfo]) -> [PlaceMarker] {
        
        let newPlace = realm.registPlaces(using: placeList)
        
        let alertTitle = newPlace.newCount > 0 ? "\(newPlace.newCount)개의 새로운 장소를 찾았습니다!" : "새로 찾은 장소가 없습니다."
        
        showAlert(title: alertTitle)
//        print(newPlace.newInfoList)
        let markers = newPlace.fetchedInfo.map { (info) -> PlaceMarker in
            let marker = PlaceMarker(place: info)
            marker.touchHandler = markerHandler
            return marker
        }
        
        return markers
        
    }
    
    private func updateAndDisplayMarker(markers: [PlaceMarker]) {
        
        currentMarkers.forEach { $0.mapView = nil }
        
        currentMarkers = markers
        
        markers.forEach { $0.mapView = naverMapView.mapView }
        
        filteringMarker()
        
    }
    
    private func updateCameraFrom(mode: CameraMode) {
        
        if let pos = mode.position {
            
            let inset: UIEdgeInsets = mode.isCenterd ? .zero : naverMapView.contentInset
            let tilt = mode.isClosed ? naverMapView.maxTilt : naverMapView.minTilt
            let zoom = mode.isClosed ? naverMapView.mapView.maxZoomLevel : naverMapView.mapView.minZoomLevel
            let size = mode.isClosed ? naverMapView.maxLocOverlaySize : naverMapView.minLocOverlaySize
            
            naverMapView.mapView.contentInset = inset
            
            let param = NMFCameraUpdateParams()
            param.tilt(to: tilt)
            param.zoom(to: zoom)
            param.scroll(to: pos)
            
            let update = NMFCameraUpdate(params: param)
            update.animation = .easeOut
            update.animationDuration = 0.7
            
            locationManager.stopUpdatingLocation()
            naverMapView.moveCameraBlockGesture(update) { [weak self] in
                
                if mode == .select(pos) {
                    self?.locationManager.stopUpdatingLocation()
                } else {
                    self?.locationManager.startUpdatingLocation()
                }
                
            }
            
            naverMapView.locOverlaySize = CGSize(width: size, height: size)
            
        }
        
    }
    
    
    private func updateMarkerDistance(pos: NMGLatLng) {
        
        currentMarkers.forEach { marker in
            
            let dis = marker.position.distance(to: pos)
            marker.distance = dis
            
        }
        
    }
    
    
    private func displayAreaOnMap() {
        
        print(#function)
        
        if let loc = CLLocationManager().location?.coordinate {
            
            naverMapView.circleOverlay.center = NMGLatLng(from: loc)
            
            naverMapView.circleOverlay.mapView = naverMapView.mapView
            
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
    
    @objc func touchPreviousCameraButton() {
        
        if let pre = previousMode {
            cameraMode = pre
        } else {
            cameraMode = .navigate
            previousMode = nil
        }
        
    }
    
    @objc func touchMenuButton() {
        
        let vc = UIViewController()
        let sideMenu = SideMenuNavigationController(rootViewController: vc)
        sideMenu.presentationStyle = .menuSlideIn
        sideMenu.blurEffectStyle = .systemUltraThinMaterial
        present(sideMenu, animated: true)
        
    }
    
    // MARK: Map Gesture
    @objc func panning(_ sender: UIPanGestureRecognizer) {
        

        let translation = sender.translation(in: naverMapView.mapView)
        let location = sender.location(in: naverMapView.mapView)
        print("panning --------------------------")
        print("translation:",translation)
        print("location:",location)
        
        if sender.state == .began {
                print("began")
            } else if sender.state == .changed {
                // rotating map camera

                let bounds = naverMapView.mapView.bounds
                let vector1 = CGVector(dx: location.x - bounds.midX, dy: location.y - bounds.midY)
                let vector2 = CGVector(dx: vector1.dx + translation.x, dy: vector1.dy + translation.y)
                let angle1 = atan2(vector1.dx, vector1.dy)
                let angle2 = atan2(vector2.dx, vector2.dy)
                let delta = (angle2 - angle1) * 180.0 / Double.pi
                
                let param = NMFCameraUpdateParams()
                param.rotate(by: delta)
                let update = NMFCameraUpdate(params: param)

                naverMapView.mapView.moveCamera(update)
                naverMapView.mapView.locationOverlay.heading += delta
                
                
//                print(delta)
            } else if sender.state == .ended {
                print("end")
            }

            sender.setTranslation(.zero, in: naverMapView.mapView)
        
    }
    
    @objc func pinch(_ sender: UIPinchGestureRecognizer) {
        
        let zoom = naverMapView.currentZoom
        let tilt = naverMapView.currentTilt
        let size = naverMapView.locOverlaySize.width
        
        print("pinch-------------------------------------")
        print("scale:", sender.scale)
        print("zoom:", zoom)
        print("tilt:", tilt)

        let minZoom = naverMapView.mapView.minZoomLevel
        let maxZoom = naverMapView.mapView.maxZoomLevel
        
        let minSize = naverMapView.minLocOverlaySize
        let maxSize = naverMapView.maxLocOverlaySize
        
        if sender.state == .began {
            print("start")
        } else if sender.state == .changed {
            
            let deltaZoom = sender.scale-1
            let deltaTilt = (naverMapView.maxTilt - naverMapView.minTilt) * deltaZoom / (maxZoom-minZoom)
            let deltaSize = (maxSize - minSize) * deltaZoom / (maxZoom - minZoom)
            
            // Camera Update
            let param = NMFCameraUpdateParams().then {
                $0.zoom(by: deltaZoom)
                
                if tilt + deltaTilt < naverMapView.minTilt {
                    $0.tilt(to: naverMapView.minTilt)
                } else {
                    $0.tilt(by: deltaTilt)
                }
                
            }
            
            let update = NMFCameraUpdate(params: param)
            naverMapView.mapView.moveCamera(update)
            
            // Location Overlay Update
            let newSize = size + deltaSize < minSize ? minSize : (size + deltaSize > maxSize ? maxSize : deltaSize + size)
            naverMapView.locOverlaySize = CGSize(width: newSize, height: newSize)
            

        } else if sender.state == .ended {
            print("ended")
        }
        
        sender.scale = 1
        
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
            locationManager.startUpdatingLocation()
//            naverMapView.mapView.positionMode = .direction
//            print(locationManager.currentLatLng())
            
        case .authorizedWhenInUse:
            print("authorized when in use")
            CLLocationManager().requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
//            print(CLLocationManager().location)
//            naverMapView.mapView.positionMode = .direction
//            print(CLLocationManager().location)
//            locationManager.startUpdatingLocation()
//            print(CLLocationManager().location)
//            naverMapView.mapView.locationOverlay.icon = NMFOverlayImage(image: UIImage(systemName: "person.fill")!)
//            print(naverMapView.mapView.locationOverlay.icon.image)
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
        
        let update = NMFCameraUpdate(scrollTo: location)
        naverMapView.mapView.moveCamera(update)
        naverMapView.mapView.locationOverlay.location = location
        
        updateMarkerDistance(pos: location)
        
    }

    
    func locationManagerDidStartLocationUpdates(_ locationManager: NMFLocationManager!) {
        print("StartLocationUpdates")
        
    }
    
    func locationManagerDidStopLocationUpdates(_ locationManager: NMFLocationManager!) {
        print("StopLocationUpdates")
        
    }
    
}


// MARK: - Circle Menu Delegate
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
//            naverMapView.mapView.positionMode = .disabled
            searchNearPlace()
        case .vision:
            isMarkerFilterOn.toggle()
            break
        case .userInfo:
            break
        }
    }
    
    
}
