//
//  ViewController.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2022/11/01.
//

import UIKit
import Kingfisher

class PlaceInfoViewController: BaseViewController {
    
    let place: CommonPlaceInfo
    let mainInfoVC: MainInfoViewController
    
    let placeInfoView = PlaceInfoView()
    
    override func loadView() {
        view = placeInfoView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addContentVC()
        configureImage()
    }
    
    func configureImage() {
        
        placeInfoView.imageView.kf.setImage(with: URL(string: place.image), options: [.transition(.fade(0.3))])
        
    }
    
    private func addContentVC() {
        
        addChild(mainInfoVC)
        
        placeInfoView.containerView.addSubview(mainInfoVC.view)
        
        mainInfoVC.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        mainInfoVC.didMove(toParent: self)
        
    }
    
    init(place: CommonPlaceInfo){
        self.mainInfoVC = MainInfoViewController(place: place)
        self.place = place
        super.init()
    }
   

}
