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
    let backgroundImageView = UIImageView()
    let titleLabel = UILabel()
    
    init(place: CommonPlaceInfo, mainInfoVC: MainInfoViewController){
        self.mainInfoVC = mainInfoVC
        self.place = place
        super.init()
        backgroundImageView.contentMode = .scaleAspectFill
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSubviews()
        addContentVC()
        configureImage()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.tintColor = .tintColor
    }
    
    // MARK: - Navigation Item
    override func configureNavigationItem() {
        guard let naviBar = navigationController?.navigationBar else { return }
        naviBar.tintColor = .white
        
        let closeButton = UIBarButtonItem(image: UIImage(systemName: "chevron.left")?.applyingSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 18, weight: .heavy)), style: .plain, target: self, action: #selector(touchCloseButton(_:)))
        
        titleLabel.font = .systemFont(ofSize: 22, weight: .bold)
        titleLabel.text = place.title
        titleLabel.textColor = .tintColor.withAlphaComponent(0.0)
        
        let standard = UINavigationBarAppearance()
        standard.configureWithTransparentBackground()

        navigationItem.leftBarButtonItem = closeButton
        navigationItem.titleView = titleLabel
        navigationItem.standardAppearance = standard
    }
    
    // MARK: - Action Method
    @objc func touchCloseButton(_ sender: UIBarButtonItem) {
        if isModal {
            dismiss(animated: true)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
}

// MARK: - Helper Method
extension PlaceInfoViewController {
    private func configureSubviews() {
        placeInfoView.delegate = self
        placeInfoView.imageContainer.addSubview(backgroundImageView)
        view.addSubview(placeInfoView)
        
        placeInfoView.snp.makeConstraints { $0.edges.equalToSuperview()
        }
        
        backgroundImageView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(view.snp.top).priority(.high)
            make.height.greaterThanOrEqualTo(placeInfoView.imageContainer.snp.height)
        }
    }
    
    private func configureImage() {
        let url = URL(string: place.image)
        
        backgroundImageView.kf.setImage(with: url, options: [.transition(.fade(0.3))])
    }
    
    private func addContentVC() {
        addChild(mainInfoVC)
        placeInfoView.containerView.addSubview(mainInfoVC.view)
        mainInfoVC.view.snp.makeConstraints { $0.edges.equalToSuperview()
        }
        
        mainInfoVC.didMove(toParent: self)
    }
    
    private func setNavigationBarColor(with alpha: CGFloat) {
        navigationItem.standardAppearance?.backgroundColor = UIColor.white.withAlphaComponent(alpha)
        navigationController?.navigationBar.tintColor = UIColor.white.colorWithBrightness(brightness: 1-alpha)
        titleLabel.textColor = .tintColor.withAlphaComponent(alpha)
    }
}

// MARK: - ScrollView Delegate
extension PlaceInfoViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let imageContainerHeight = placeInfoView.imageContainer.frame.height
        let inset = backgroundImageView.frame.height - imageContainerHeight
        let maxOffset = (imageContainerHeight / 2) - 100
        
        let alpha = (scrollView.contentOffset.y + inset) / (inset + maxOffset)
        print(imageContainerHeight, inset, maxOffset)
        print("alpha:\(alpha)")
        
        setNavigationBarColor(with: imageContainerHeight > 0 ? alpha : 0.0)
        
//        if scrollView.contentOffset.y >= maxOffset {
//            print("OK")
//        } else {}
    }
    
}
