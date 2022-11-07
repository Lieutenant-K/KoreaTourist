//
//  ViewController.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2022/11/01.
//

import UIKit
import Kingfisher
import SnapKit

class PlaceInfoViewController: BaseViewController {
    
    let place: CommonPlaceInfo
    let mainInfoVC: MainInfoViewController
    
    let placeInfoView = PlaceInfoView()
    
    let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSubviews()
        addContentVC()
        configureImage()
    }
    
    func configureSubviews() {
        
        placeInfoView.delegate = self
        
        view.addSubview(placeInfoView)
        placeInfoView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        placeInfoView.imageContainer.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(view.snp.top).priority(.high)
            make.height.greaterThanOrEqualTo(placeInfoView.imageContainer.snp.height)
        }
        
    }
    
    func configureImage() {
        
        let url = URL(string: place.image)
        
        imageView.kf.setImage(with: url, options: [.transition(.fade(0.3))])
        
    }
    
    override func configureNavigationItem() {
        guard let naviBar = navigationController?.navigationBar else { return }
        
//        navigationController?.isNavigationBarHidden = true
        
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

extension PlaceInfoViewController: UIScrollViewDelegate {
    
}
