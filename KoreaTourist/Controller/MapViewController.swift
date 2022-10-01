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
            guard let loc = MapViewController.locationManager.location?.coordinate else { return nil}
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
    
    static let locationManager = CLLocationManager().then {
        $0.desiredAccuracy = kCLLocationAccuracyBest
        
//        $0.distanceFilter = 1
        
    }
    
    static let progressHUD = JGProgressHUD(automaticStyle: ()).then {
        $0.position = .center
        $0.animation = JGProgressHUDFadeAnimation()
        $0.indicatorView = JGProgressHUDIndeterminateIndicatorView()
        $0.textLabel.text = "장소를 찾는 중..."
    }
    
    var currentMarkers = [PlaceMarker]()
    
    var markerHandler: NMFOverlayTouchHandler?
    
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
        
//        locationManager.add(self)
        
        checkLocationService()
        
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
    
    private func checkLocationService() {
        
        if CLLocationManager.locationServicesEnabled() {
            Self.locationManager.delegate = self
        } else {
            let cancel = UIAlertAction(title: "확인", style: .default)
            let ok: UIAlertAction = .goSettingAction
            showAlert(title: "위치 서비스를 활성화 해주세요!", message: "사용자의 위치를 가져오려면 위치 서비스가 필요해요", actions: [cancel, ok])
        }
        
    }
    
    // MARK: Navigation Item
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
    
    
    // MARK: Marker Touch Handler
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
    
    // MARK: Discover Place
    private func showDiscoverAlert(target marker: PlaceMarker) {
        
        if marker.placeInfo.isDiscovered {
//            print("이미 발견됨!!!!")
            let vc = DetailViewController(place: marker.placeInfo)
            let navi = UINavigationController(rootViewController: vc)
            present(navi, animated: true)
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
            
            naverMapView.makeToast("\(Int(PlaceMarker.minimumDistance))m 이내로 접근해주세요", point: .markerTop, title: "아직 발견할 수 없어요!", image: nil, completion: nil)
            
            
//            showAlert(title: "아직 발견할 수 없어요!", message: "\(Int(PlaceMarker.minimumDistance))m 이내로 접근해주세요")
        }
        
    }
    
    private func discoverPlace(about marker: PlaceMarker) {
        
        realm.discoverPlace(with: marker.placeInfo.contentId)
        marker.updateMarkerAppearnce()
        
        present(PopupViewController(place: marker.placeInfo), animated: true)
//        naverMapView.mapView.positionMode = .normal
//        locationManager.stopUpdatingLocation()
        
    }
    
    
    // MARK: Search Near Place
    func searchNearPlace() {
        
        
        guard let loc = Self.locationManager.location?.coordinate else {
//            showAlert(title: "현재 위치를 찾을 수 없습니다.")
            naverMapView.makeToast("위치 서비스가 활성화 됐는지 확인해주세요", point: .top, title: "현재 위치를 찾을 수 없어요 :(", image: nil, completion: nil)
            return
        }
        
        let circle = Circle(x: loc.longitude, y: loc.latitude, radius: Circle.defaultRadius)
        
        let failure: () -> () = { [weak self] in

            self?.naverMapView.makeToast("장소를 찾을 수 없어요 🥲", point: .top, title: nil, image: nil, completion: nil)
        }
        
        Self.progressHUD.show(in: naverMapView, animated: true)
        
        realm.fetchNearPlace(location: circle, failureHandler: failure) { [weak self] newCount, placeList in
            
            Self.progressHUD.dismiss(animated: true)
            
            if placeList.count > 0 {
//                print(placeList)
                
                let markers = placeList.map { (info) -> PlaceMarker in
                    let marker = PlaceMarker(place: info)
                    marker.touchHandler = self?.markerHandler
                    return marker
                }
                
                self?.updateAndDisplayMarker(markers: markers)
                self?.cameraMode = .search
                
                let title = newCount > 0 ? "\(newCount)개의 새로운 장소를 찾았어요!!" : "새로운 장소를 찾지 못했어요!"
                

                self?.naverMapView.makeToast(title, point: .top, title: nil, image: nil, completion: nil)
                
            } else {
                

                self?.naverMapView.makeToast("\(Int(Circle.defaultRadius))m 이내에 찾을 장소가 없습니다!")
            }
            
            self?.displayAreaOnMap(location: loc)
        }
        
            
    }
    
    private func displayAreaOnMap(location: CLLocationCoordinate2D) {
        
//        print(#function)
        
        naverMapView.circleOverlay.center = NMGLatLng(lat: location.latitude, lng: location.longitude)
        
        naverMapView.circleOverlay.mapView = naverMapView.mapView
            
        
        
    }
    
    
    // MARK: Update, Filtering Marker
    
    private func updateAndDisplayMarker(markers: [PlaceMarker]) {
        
        currentMarkers.forEach { $0.mapView = nil }
        
        currentMarkers = markers
        
        markers.forEach { $0.mapView = naverMapView.mapView }
        
        filteringMarker()
        
    }
    
    func filteringMarker() {
        
        currentMarkers.forEach { $0.hidden = isMarkerFilterOn ? ($0.placeInfo.isDiscovered ? true : false) : false }
        
    }
    
    private func updateMarkerDistance(pos: NMGLatLng) {
        
        currentMarkers.forEach { marker in
            
            let dis = marker.position.distance(to: pos)
            marker.distance = dis
            
        }
        
    }
    
    
    // MARK: Moving Camera (Camera Mode)
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
    
    
    // MARK: Geocoding
    
    private func updateGeoTitle(loc: CLLocation) {
        
        CLGeocoder().reverseGeocodeLocation(loc, preferredLocale: Locale(identifier: "ko_KR")) { [weak self] placeMark, error in
            
            if let place = placeMark?.first {
                self?.naverMapView.geoTitleLabel.text = [(place.locality ?? ""),(place.subLocality ?? "")].joined(separator: " ")
            }
            
        }
        
    }
    
    // MARK: User Interface Change
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {

        currentMarkers.forEach { $0.updateMarkerAppearnce() }
        
    }
    
    // MARK: - Action Method
    
    
    @objc func touchPreviousCameraButton() {
        
        if let pre = previousMode {
            cameraMode = pre
        } else {
            cameraMode = .navigate
            previousMode = nil
        }
        
    }
    
    @objc func touchMenuButton() {
        /*
        let vc = UIViewController()
        let sideMenu = SideMenuNavigationController(rootViewController: vc)
        sideMenu.presentationStyle = .menuSlideIn
        sideMenu.blurEffectStyle = .systemUltraThinMaterial
        present(sideMenu, animated: true)
        */
    }
    
    
    // MARK: Map Gesture
    
    
    
    // MARK: Panning
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
    
    // MARK: Pinch
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


extension MapViewController: CLLocationManagerDelegate {
    
    // MARK: Authorization
    func checkAuthorization(auth: CLAuthorizationStatus) {
        
        switch auth {
        case .notDetermined:
            print("not determined")
            Self.locationManager.requestWhenInUseAuthorization()
        case .restricted:
            print("restricted")
            let cancel = UIAlertAction(title: "확인", style: .cancel)
            let goSetting: UIAlertAction = .goSettingAction
            showAlert(title: "위치 서비스를 사용할 권한이 없어요!", message: "자녀 보호 기능 등이 활성화 됐는지 확인해주세요", actions: [cancel, goSetting])
        case .denied:
            print("denied")
            let cancel = UIAlertAction(title: "나가기", style: .destructive)
            let ok: UIAlertAction = .goSettingAction
            showAlert(title: "위치 정보에 대한 사용 권한이 거부됐어요", message: "근처의 장소들을 찾기 위해서는 사용자의 위치 데이터가 필요해요!", actions: [cancel, ok])
            // 설정으로 안내하는 코드
        case .authorizedAlways:
            print("always authorized")
            Self.locationManager.startUpdatingLocation()
            
        case .authorizedWhenInUse:
            print("authorized when in use")
//            CLLocationManager().requestAlwaysAuthorization()
            if Self.locationManager.accuracyAuthorization == .reducedAccuracy {
                showAlert(title: "정확한 위치 정보를 허용해주세요!", message: "실제와 다른 위치가 검색될 수 있어요")
            }
            Self.locationManager.startUpdatingLocation()
        default:
            print("default")
        }
        
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        
        let auth = manager.authorizationStatus
        
        checkAuthorization(auth: auth)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = locations.last else { return }
        
        let pos = NMGLatLng(from: location.coordinate)
        
        print("UpdateLocation", pos.lat, pos.lng)
        
        let update = NMFCameraUpdate(scrollTo: pos)
        naverMapView.mapView.moveCamera(update)
        naverMapView.mapView.locationOverlay.location = pos
        
        updateMarkerDistance(pos: pos)
        
        updateGeoTitle(loc: location)
        
    }
    
    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        print(#function)
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
            let vc = CollectionViewController()
            let navi = UINavigationController(rootViewController: vc)
            navi.modalPresentationStyle = .fullScreen
            navi.modalTransitionStyle = .coverVertical
            present(navi,animated: true)
            break
        }
    }
    
    
}
