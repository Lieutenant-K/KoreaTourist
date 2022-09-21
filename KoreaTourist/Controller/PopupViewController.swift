//
//  PopupViewController.swift
//  KakaoMap
//
//  Created by 김윤수 on 2022/09/15.
//

import UIKit
import SnapKit
import Kingfisher

final class PopupViewController: BaseViewController {
    
    let popupView = PopupView()
    
    let placeInfo: CommonPlaceInfo
    
    override func loadView() {
        view = popupView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurePopupView()
        configureButtonAction()
    }
    
    private func configurePopupView() {
        
        popupView.titleLabel.text = placeInfo.title
        popupView.descriptLabel.text = "\(placeInfo.addr1)\n\(placeInfo.addr2)"
        popupView.imageView.kf.setImage(with: URL(string: placeInfo.image))
        
    }
    
    private func configureButtonAction() {
        
        popupView.okButton.addTarget(self, action: #selector(touchOkButton(_:)), for: .touchUpInside)
        popupView.detailButton.addTarget(self, action: #selector(touchDetailButton(_:)), for: .touchUpInside)
        
    }
    
    private func presentDetailViewController() {
        
        APIManager.shared.requestCommonPlaceInfo(contentId: placeInfo.contentId) { [weak self] data in
            if let weakSelf = self {
                weakSelf.realm.updateCommonPlaceInfo(with: weakSelf.placeInfo, using: data)
                let vc = DetailViewController(place: data)
                let navi = UINavigationController(rootViewController: vc)
                weakSelf.present(navi, animated: true)
            }
        }
        
    }
    
    @objc func touchOkButton(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @objc func touchDetailButton(_ sender: UIButton) {
        
        presentDetailViewController()
        
    }
    
    init(place: CommonPlaceInfo) {
        placeInfo = place
        super.init()
        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overFullScreen
    }
    
    
    
    
}
