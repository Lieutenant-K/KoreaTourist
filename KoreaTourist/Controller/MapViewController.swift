//
//  ViewController.swift
//  KakaoMap
//
//  Created by 김윤수 on 2022/09/09.
//

import UIKit
import NMapsMap
import CircleMenu
import CoreLocation
import Toast
import JGProgressHUD

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
    var naverMapView = MapView()
    var currentMarkers = [PlaceMarker]()
    var isMarkerFilterOn = false {
        didSet {
            let active = isMarkerFilterOn ? "활성화" : "비활성화"
            naverMapView.makeToast("미발견 장소만 보기 ", point: .top, title: active, image: nil, completion: nil)
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
    
    static let locationManager = CLLocationManager().then {
        $0.desiredAccuracy = kCLLocationAccuracyBest
        $0.distanceFilter = 10
    }
    
    static let progressHUD = JGProgressHUD(automaticStyle: ()).then {
        $0.position = .center
        $0.animation = JGProgressHUDFadeAnimation()
        $0.indicatorView = JGProgressHUDIndeterminateIndicatorView()
        $0.textLabel.text = "장소를 찾는 중..."
    }
    
    // MARK: - LifeCycle
    
    override func loadView() {
        view = naverMapView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addObservers()
        addTarget()
        configureMenuButton()
        Self.locationManager.delegate = self
//        realm.printRealmFileURL()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        currentMarkers.forEach { $0.updateMarkerAppearnce() }
    }
}

// MARK: - Helper Method
extension MapViewController {
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(deviceOrientationChanged), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    private func addTarget() {
        naverMapView.cameraButton.addTarget(self, action: #selector(touchPreviousCameraButton), for: .touchUpInside)
        naverMapView.trackButton.addTarget(self, action: #selector(touchTrackButton(_:)), for: .touchUpInside)
    }
    
    private func configureMenuButton() {
        naverMapView.circleButton.delegate = self
        naverMapView.circleButton.buttonsCount = Menu.allCases.count
    }
    
    private func createMarkerHandler() -> NMFOverlayTouchHandler {
        return { [weak self] marker in
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
    
    private func createFailureHandler() -> (FailureReason) -> () {
        return { [weak self] reason in
            var message = ""
            var title = ""
            
            switch reason {
            case .noData:
                title = "주변에서 특별한 장소를 찾지 못했어요"
                message = "다른 새로운 곳에서 다시 시도해보세요!"
            case let .apiError(error):
                title = "서버에서 문제가 발생했어요"
                message = "에러: \(error.cmmMsgHeader.errMsg)\n나중에 다시 시도해주세요"
            }
            
            Self.progressHUD.dismiss(animated: true)
            
            self?.naverMapView.makeToast(message, point: .top, title: title, image: nil, completion: nil)
        }
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
            
            Self.locationManager.stopUpdatingLocation()
            naverMapView.moveCameraBlockGesture(update) {
                if mode == .navigate || mode == .search {
                    Self.locationManager.startUpdatingLocation()
                }
            }
            
            naverMapView.locOverlaySize = CGSize(width: size, height: size)
        }
    }
    
    private func updateGeoTitle(loc: CLLocation) {
        CLGeocoder().reverseGeocodeLocation(loc, preferredLocale: Locale(identifier: "ko_KR")) { [weak self] placeMark, error in
            if let place = placeMark?.first {
                self?.naverMapView.geoTitleLabel.text = [(place.locality ?? ""),(place.subLocality ?? "")].joined(separator: " ")
            }
        }
    }
}

// MARK: Place Control Method
extension MapViewController {
    private func showDiscoverAlert(target marker: PlaceMarker) {
        if marker.placeInfo.isDiscovered {
            let sub = SubInfoViewController(place: marker.placeInfo)
            let main = MainInfoViewController(place: marker.placeInfo, subInfoVC: sub)
            let vc = PlaceInfoViewController(place: marker.placeInfo, mainInfoVC: main)
            let navi = UINavigationController(rootViewController: vc)
            navi.modalPresentationStyle = .fullScreen
            present(navi, animated: true)
            return
        }
        
        if marker.distance <= PlaceMarker.minimumDistance {
            let ok = UIAlertAction(title: "네", style: .cancel) { [weak self] _ in
                self?.discoverPlace(about: marker)
            }
            let cancel = UIAlertAction(title: "아니오", style: .default)
            let actions = [cancel, ok]
            
            showAlert(title: "이 장소를 발견하시겠어요?", actions: actions)
        } else {
            naverMapView.makeToast("\(Int(PlaceMarker.minimumDistance))m 이내로 접근해주세요", point: .markerTop, title: "아직 발견할 수 없어요!", image: nil, completion: nil)
        }
        
    }
    
    private func discoverPlace(about marker: PlaceMarker) {
        realm.discoverPlace(with: marker.placeInfo.contentId)
        
        marker.updateMarkerAppearnce()
        
        present(PopupViewController(place: marker.placeInfo), animated: true)
    }
    
    func searchNearPlace() {
        guard let loc = Self.locationManager.location?.coordinate else {
            naverMapView.makeToast("위치 서비스가 활성화 됐는지 확인해주세요", point: .top, title: "현재 위치를 찾을 수 없어요 :(", image: nil, completion: nil)
            return
        }
        
        let circle = Circle(x: loc.longitude, y: loc.latitude, radius: Circle.defaultRadius)
        
        Self.progressHUD.show(in: naverMapView, animated: true)
        
        realm.fetchNearPlace(location: circle, failureHandler: createFailureHandler()) { [weak self] newCount, placeList in
            
            Self.progressHUD.dismiss(animated: true)
            
            if placeList.count > 0 {
                let title = newCount > 0 ? "\(newCount)개의 새로운 장소를 찾았어요!!" : "새로운 장소를 찾지 못했어요!"
                let markers = placeList.map {
                    let marker = PlaceMarker(place: $0)
                    marker.touchHandler = self?.createMarkerHandler()
                    return marker
                }
                
                self?.updateAndDisplayMarker(markers: markers)
                self?.cameraMode = .search
                self?.naverMapView.makeToast(title, point: .top, title: nil, image: nil, completion: nil)
                
            } else {
                self?.naverMapView.makeToast("\(Int(Circle.defaultRadius))m 이내에 찾을 장소가 없습니다!")
            }
            
            self?.displayAreaOnMap(location: loc)
        }
    }
}

// MARK: - Overlay Control Method
extension MapViewController {
    private func displayAreaOnMap(location: CLLocationCoordinate2D) {
        naverMapView.circleOverlay.center = NMGLatLng(lat: location.latitude, lng: location.longitude)
        naverMapView.circleOverlay.mapView = naverMapView.mapView
    }
    
    private func updateAndDisplayMarker(markers: [PlaceMarker]) {
        currentMarkers.forEach { $0.mapView = nil }
        currentMarkers = markers.map {
            $0.mapView = naverMapView.mapView
            return $0
        }
        
        filteringMarker()
    }
    
    func filteringMarker() {
        currentMarkers.forEach {
            $0.hidden = isMarkerFilterOn ? ($0.placeInfo.isDiscovered ? true : false) : false
        }
    }
    
    private func updateMarkerDistance(pos: NMGLatLng) {
        currentMarkers.forEach {
            $0.distance = $0.position.distance(to: pos)
        }
    }
}

// MARK: - Action Method
extension MapViewController {
    @objc private func deviceOrientationChanged() {
        let orientation = UIDevice.current.orientation
        
        if orientation.isValidInterfaceOrientation {
            Self.locationManager.changeHeadingOrientation(with: orientation)
            
            naverMapView.deviceOrientationDidChange(mode: cameraMode, orient: orientation)
        }
    }
    
    @objc func touchPreviousCameraButton() {
        if let pre = previousMode {
            cameraMode = pre
        } else {
            cameraMode = .navigate
            previousMode = nil
        }
    }

    @objc func touchTrackButton(_ sender: UIButton) {
        if CLLocationManager.headingAvailable() {
            sender.isSelected.toggle()
        } else {
            showAlert(title: "방향 추적 기능을 사용하실 수 없어요!")
        }
    }
}

// MARK: - LocationManagerDelegate
extension MapViewController: CLLocationManagerDelegate {
    
    // MARK: Authorization
    func checkAuthorization(auth: CLAuthorizationStatus) {
        switch auth {
        case .notDetermined:
            Self.locationManager.requestWhenInUseAuthorization()
            
        case .restricted:
            let cancel = UIAlertAction(title: "확인", style: .cancel)
            let goSetting: UIAlertAction = .goSettingAction
            
            showAlert(title: "위치 서비스를 사용할 권한이 없어요!", message: "자녀 보호 기능 등이 활성화 됐는지 확인해주세요", actions: [cancel, goSetting])
            
        case .denied:
            let cancel = UIAlertAction(title: "나가기", style: .destructive)
            let ok: UIAlertAction = .goSettingAction
            
            showAlert(title: "위치 정보에 대한 사용 권한이 거부됐어요", message: "근처의 장소들을 찾기 위해서는 사용자의 위치 데이터가 필요해요!", actions: [cancel, ok])
            
        case .authorizedWhenInUse, .authorizedAlways:
            if Self.locationManager.accuracyAuthorization == .reducedAccuracy {
                showAlert(title: "정확한 위치 정보를 허용해주세요!", message: "실제와 다른 위치가 검색될 수 있어요")
            }
            
            Self.locationManager.startUpdatingLocation()
            
        default:
            print("default")
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkAuthorization(auth: manager.authorizationStatus)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        let pos = NMGLatLng(from: location.coordinate)
        let update = NMFCameraUpdate(scrollTo: pos)
        
        print("UpdateLocation", pos.lat, pos.lng)
        
        naverMapView.mapView.moveCamera(update)
        naverMapView.mapView.locationOverlay.location = pos
        
        updateMarkerDistance(pos: pos)
        
        updateGeoTitle(loc: location)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        let heading = newHeading.trueHeading
        let update = NMFCameraUpdate(heading: heading)
        
        naverMapView.mapView.moveCamera(update)
        naverMapView.mapView.locationOverlay.heading = heading
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
        let menu = Menu.allCases[atIndex]
        
        switch menu {
        case .search:
            searchNearPlace()
            
        case .vision:
            isMarkerFilterOn.toggle()

        case .userInfo:
            let vc = CollectionViewController()
            let navi = UINavigationController(rootViewController: vc)
            navi.modalPresentationStyle = .fullScreen
            navi.modalTransitionStyle = .coverVertical
            present(navi,animated: true)
        }
    }
}
