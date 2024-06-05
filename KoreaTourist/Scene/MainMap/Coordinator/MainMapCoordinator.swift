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
        let lab: MapLaboratoryButton?
        
        #if DEV
        lab = MapLaboratoryButton(map: map)
        #else
        lab = nil
        #endif
        
        let viewController = MainMapViewController(viewModel: viewModel, map: map, compass: compass, headTrack: headTrackBtn, camera: camera, lab: lab)
        
        self.navigationController.pushViewController(viewController, animated: false)
    }
}

extension MainMapCoordinator {
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
        let coordinator = PopupCoordinator(navigationController: self.navigationController)
        coordinator.finishDelegate = self
        self.childCoordinators.append(coordinator)
        coordinator.start(placeInfo: place)
    }
    
    func pushPlaceCollectionScene() {
        let coordinator = MyCollectionCoordinator(navigationController: self.navigationController)
        coordinator.finishDelegate = self
        self.childCoordinators.append(coordinator)
        coordinator.start()
    }
}

extension MainMapCoordinator: PopupFinishDelegate {
    func finish(coordinator: Coordinator) {
        if let index = self.childCoordinators.firstIndex(where: { $0 === coordinator }) {
            self.childCoordinators.remove(at: index)
        }
    }
    
    func pushPlaceDetailScene(place: CommonPlaceInfo) {
        let coordinator = PlaceDetailCoordinator(navigationController: self.navigationController)
        self.childCoordinators.append(coordinator)
        coordinator.finishDelegate = self
        coordinator.start(placeInfo: place, isModal: true)
    }
}
