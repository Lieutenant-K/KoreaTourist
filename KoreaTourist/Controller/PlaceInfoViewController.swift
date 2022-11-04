//
//  ViewController.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2022/11/01.
//

import UIKit

class PlaceInfoViewController: BaseViewController {
    
    let placeInfoView = PlaceInfoView()
    let mainInfoVC = MainInfoViewController()
    
    override func loadView() {
        view = placeInfoView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addContentVC()
        
    }
    
    private func addContentVC() {
        
        addChild(mainInfoVC)
        
        placeInfoView.containerView.addSubview(mainInfoVC.view)
        
        mainInfoVC.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        mainInfoVC.didMove(toParent: self)
        
    }
    

   

}
