//
//  HeadTrackButton.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2022/10/09.
//

import UIKit
import NMapsMap

final class HeadTrackButton: UIButton {
    
    weak var locationOverlay: NMFLocationOverlay?
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                MapViewController.locationManager.startUpdatingHeading()
                locationOverlay?.icon = NMFOverlayImage(image: .navigation)
            } else {
                MapViewController.locationManager.stopUpdatingHeading()
                locationOverlay?.icon  = NMFOverlayImage(image: .location)
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
    
    convenience init(location: NMFLocationOverlay) {
        self.init(type: .system)
        locationOverlay = location
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureButton()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
