//
//  ViewController.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2022/11/01.
//

import UIKit

class PlaceInfoViewController: BaseViewController {
    
    let placeInfoView = PlaceInfoView()
    let commonInfoVC = CommonInfoViewController()
    
    override func loadView() {
        view = placeInfoView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addContentVC()
        
    }
    
    private func addContentVC() {
        
        addChild(commonInfoVC)
        
        placeInfoView.containerView.addSubview(commonInfoVC.view)
        
        commonInfoVC.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        commonInfoVC.didMove(toParent: self)
        
    }
    

   

}
