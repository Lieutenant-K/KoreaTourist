//
//  HeadTrackButton.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2022/10/09.
//

import UIKit

final class HeadTrackButton: UIButton {
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                MapViewController.locationManager.startUpdatingHeading()
            } else {
                MapViewController.locationManager.stopUpdatingHeading()
            }
        }
    }
    
    private func configureButton() {
        
        let selectImage = UIImage(systemName: "safari.fill")?.applyingSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 25, weight: .semibold))
        
        let deselectImage = UIImage(systemName: "safari")?.applyingSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 25, weight: .semibold))
        
        setImage(deselectImage, for: .normal)
        setImage(selectImage, for: .selected)
        backgroundColor = .white
        
        layer.shadowOffset = .zero
        layer.shadowOpacity = 0.3
        
        
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureButton()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
