//
//  DetailView.swift
//  KakaoMap
//
//  Created by 김윤수 on 2022/09/16.
//

import UIKit
import SnapKit
import Then

class DetailView: BaseView {
    
    private let visual = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
    
    static var headerWidth:CGFloat {
        UIScreen.main.bounds.width
    }
    static var headerHeight:CGFloat {
        2 * headerWidth / 3
    }
    
    let imageHeaderView = ImageHeaderView(itemSize: CGSize(width: headerWidth, height: headerHeight)).then {
        
        $0.frame = CGRect(origin: .zero, size: CGSize(width: 0, height: headerHeight))
        
        $0.collectionView.register(DetailImageCell.self, forCellWithReuseIdentifier: DetailImageCell.reuseIdentifier)
        
    }
    
    lazy var tableView = UITableView().then { view in

        Section.allCases.forEach { section in
            section.typeOfCell.forEach { type in
                view.register(type, forCellReuseIdentifier: type.reuseIdentifier)
            }
        }
        
        view.tableHeaderView = imageHeaderView
        view.backgroundColor = .clear
        
    }
    
    override func setBackground() {
        backgroundColor = .systemBackground
        addSubview(visual)
        
    }
    
    override func addSubviews() {
        addSubview(visual)
        visual.contentView.addSubview(tableView)
    }
    
    override func addConstraint() {
        visual.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
    }
    
    
}
