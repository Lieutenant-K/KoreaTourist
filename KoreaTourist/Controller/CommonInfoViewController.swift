//
//  CommonInfoViewController.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2022/11/02.
//

import UIKit

class CommonInfoViewController: BaseViewController {
    
    let introVC = IntroController()
    
    let commonInfoView = CommonInfoView()
    
    override func loadView() {
        view = commonInfoView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addChileVC()
        
    }
    
    func addChileVC() {
        
        addChild(introVC)
        
        commonInfoView.placeInfoTypeView.contentView.addSubview(introVC.view)
        
        introVC.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        introVC.didMove(toParent: self)
        
        
    }


}
