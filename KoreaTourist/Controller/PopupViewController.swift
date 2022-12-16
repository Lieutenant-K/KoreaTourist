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
        popupView.descriptLabel.text = "\(placeInfo.addr1) \(placeInfo.addr2)"
        popupView.imageView.kf.indicatorType = .activity
        popupView.imageView.kf.setImage(with: URL(string: placeInfo.image), placeholder: UIImage(systemName: "photo")?.applyingSymbolConfiguration(.init(weight: .light)), options: [.transition(.fade(0.5))])
        
    }
    
    private func configureButtonAction() {
        
        popupView.okButton.addTarget(self, action: #selector(touchOkButton(_:)), for: .touchUpInside)
        popupView.detailButton.addTarget(self, action: #selector(touchDetailButton(_:)), for: .touchUpInside)
        
    }
    
    @objc func touchOkButton(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @objc func touchDetailButton(_ sender: UIButton) {
        let sub = SubInfoViewController(place: placeInfo)
        let main = MainInfoViewController(place: placeInfo, subInfoVC: sub)
        let vc = PlaceInfoViewController(place: placeInfo, mainInfoVC: main)
        let navi = UINavigationController(rootViewController: vc)
        
        self.present(navi, animated: true)
    }
    
    init(place: CommonPlaceInfo) {
        placeInfo = place
        super.init()
        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overFullScreen
    }
    
    
    
    
}
