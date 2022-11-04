//
//  MainInfoViewController.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2022/11/02.
//

import UIKit

class MainInfoViewController: BaseViewController {
    
    let subInfoVC = SubInfoViewController()
    let mainInfoView = MainInfoView()
    
    override func loadView() {
        view = mainInfoView
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addChileVC()
        
    }
    
    func addChileVC() {
        
        addChild(subInfoVC)
        mainInfoView.subInfoView.addSubview(subInfoVC.view)
        
        subInfoVC.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        subInfoVC.didMove(toParent: self)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
}
