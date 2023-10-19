//
//  MainMapCoordinator.swift
//  KoreaTourist
//
//  Created by 김윤수 on 10/12/23.
//

import UIKit

final class MainMapCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let useCase = CommonMapUseCase()
        let viewModel = MapViewModel(useCase: useCase)
        viewModel.coordinator = self
        
        let map = MainMapView()
        let compass = CompassView(map: map)
        let headTrackBtn = HeadTrackButton(map: map)
        let camera = MapCameraModeButton(map: map)
        let viewController = MockMapViewController(viewModel: viewModel, map: map, compass: compass, headTrack: headTrackBtn, camera: camera)
        
        self.navigationController.pushViewController(viewController, animated: false)
    }
}

extension MainMapCoordinator {
    func pushDetailPlaceInfoScene(place: CommonPlaceInfo) {
        let sub = SubInfoViewController(place: place)
        let main = MainInfoViewController(place: place, subInfoVC: sub)
        let vc = PlaceInfoViewController(place: place, mainInfoVC: main)
        let navi = UINavigationController(rootViewController: vc)
        navi.modalPresentationStyle = .fullScreen
        self.navigationController.present(navi, animated: true)
        return
    }
    
    func showPlaceDiscoverAlert(place: CommonPlaceInfo, confirmAction: @escaping () -> ()) {
        let ok = UIAlertAction(title: "네", style: .cancel) { _ in
            confirmAction()
        }
        let cancel = UIAlertAction(title: "아니오", style: .default)
        let alertController = UIAlertController(title: "새로 발견할 수 있는 장소입니다.", message: "이 장소를 발견하시겠어요?", preferredStyle: .alert)
        alertController.addAction(ok)
        alertController.addAction(cancel)
        
        self.navigationController.present(alertController, animated: true)
    }
    
    func pushDiscoverPopupScene(place: CommonPlaceInfo) {
        let viewController = PopupViewController(place: place)
        self.navigationController.present(viewController, animated: true)
    }
    
    func pushPlaceCollectionScene() {
        let viewController = CollectionViewController()
        let navi = UINavigationController(rootViewController: viewController)
        navi.modalPresentationStyle = .fullScreen
        navi.modalTransitionStyle = .coverVertical
        self.navigationController.present(navi, animated: true)
    }
}
