//
//  OverviewController.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2022/11/02.
//

import UIKit

class IntroController: BaseViewController {
    
    let introView = IntroView()
    
    override func loadView() {
        view = introView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureIntroView()
        
    }
    
    func configureIntroView() {
        
        
    }

    

}
