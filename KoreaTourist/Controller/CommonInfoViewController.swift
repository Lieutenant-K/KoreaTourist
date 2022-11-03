//
//  CommonInfoViewController.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2022/11/02.
//

import UIKit

class CommonInfoViewController: BaseViewController {
    
    let introVC = IntroInfoController()
    let detailVC = DetailInfoViewController()
    
    let commonInfoView = CommonInfoView()
    
    override func loadView() {
        view = commonInfoView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addChileVC()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    func addChileVC() {
        
        [introVC, detailVC].forEach {
            addChild($0)
            commonInfoView.placeInfoTypeView.contentView.addSubview($0.view)
            
            $0.view.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            
            $0.didMove(toParent: self)
        }
        
        
        
        
        commonInfoView.placeInfoTypeView.contentView.snp.updateConstraints { make in
//            make.height.equalTo(introVC.introView.contentSize.height)
        }
        
        
        
    }


}
