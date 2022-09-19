//
//  BaseViewController.swift
//  KakaoMap
//
//  Created by 김윤수 on 2022/09/16.
//

import UIKit

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationItem()
        
    }
    
    func configureNavigationItem() {}
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    
    deinit {
        print("\(type(of: Self.self)) deinit")
    }
    
    // 사용 시 컴파일 오류 발생
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }

}
