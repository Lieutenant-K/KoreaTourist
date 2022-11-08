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
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setNavigationBarColor(with: 0)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.navigationBar.tintColor = .tintColor
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
    
    func setNavigationBarColor(with alpha: CGFloat) {
        
        navigationItem.standardAppearance?.backgroundColor = UIColor.white.withAlphaComponent(alpha)
        navigationItem.titleView?.alpha = alpha
        navigationController?.navigationBar.tintColor = UIColor.white.colorWithBrightness(brightness: 1-alpha)
        
        
    }
    
    override func configureNavigationItem() {
        guard let naviBar = navigationController?.navigationBar else { return }
        
        let closeButton = UIBarButtonItem(image: UIImage(systemName: "chevron.left")?.applyingSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 18, weight: .heavy)), style: .plain, target: self, action: #selector(touchCloseButton(_:)))
        
        navigationItem.leftBarButtonItem = closeButton
        
//        let personButton = UIBarButtonItem(image: UIImage(systemName: "person.fill"), style: .plain, target: nil, action: nil)
//
//        navigationItem.rightBarButtonItem = personButton
        
        naviBar.tintColor = .white
        
        navigationItem.titleView = UILabel().then {
            $0.font = .systemFont(ofSize: 22, weight: .bold)
            $0.text = place.title
            $0.textColor = .tintColor
            $0.alpha = 0.0
        }
        
        let standard = UINavigationBarAppearance()
        standard.configureWithTransparentBackground()
        standard.backgroundColor = .white
        
        let scrollEdge = UINavigationBarAppearance()
        scrollEdge.configureWithTransparentBackground()
        
        navigationItem.standardAppearance = standard
        navigationItem.scrollEdgeAppearance = scrollEdge
        
        
    }
    
    private func addContentVC() {
        
        addChild(mainInfoVC)
        
        placeInfoView.containerView.addSubview(mainInfoVC.view)
        
        mainInfoVC.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        mainInfoVC.didMove(toParent: self)
        
    }
    
    @objc func touchCloseButton(_ sender: UIBarButtonItem) {
        
        if isModal {
            dismiss(animated: true)
        } else {
            navigationController?.popViewController(animated: true)
        }
        
    }
    
    init(place: CommonPlaceInfo){
        self.mainInfoVC = MainInfoViewController(place: place)
        self.place = place
        super.init()
    }
   

}

extension PlaceInfoViewController: UIScrollViewDelegate {
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
//        guard let naviBar = navigationController?.navigationBar else {return }
        
        let imageContainerHeight = placeInfoView.imageContainer.frame.height
        
        let inset = imageView.frame.height - imageContainerHeight
        
        let maxOffset = (imageContainerHeight / 2) - 100
        
        let alpha = (scrollView.contentOffset.y + inset) / (inset + maxOffset)
        
//        print("alpha:\(alpha)")
        
        setNavigationBarColor(with: alpha)
        /*
        navigationItem.standardAppearance?.backgroundColor = UIColor.white.withAlphaComponent(alpha)
        navigationItem.titleView?.alpha = alpha
        naviBar.tintColor = UIColor.white.colorWithBrightness(brightness: 1-alpha)
        */
        
        if scrollView.contentOffset.y >= maxOffset {
            print("OK")
            
//            navigationItem.standardAppearance?.backgroundColor = UIColor.systemBackground.withAlphaComponent(1.0)
        } else {
//            print("No")
//            navigationItem.standardAppearance?.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.0)
        }
//        print(scrollView.contentOffset.y + inset)
    }
    
}
