//
//  DetailView.swift
//  KakaoMap
//
//  Created by 김윤수 on 2022/09/16.
//

import UIKit
import SnapKit

class DetailView: BaseView {
    
    let imageHeaderView: ImageHeaderView = {
        
        let width = UIScreen.main.bounds.width
        let height = 2*width/3
        
        let view = ImageHeaderView(itemSize: CGSize(width: width, height: height))
        
        view.frame = CGRect(origin: .zero, size: CGSize(width: 0, height: height))
        
        view.collectionView.register(DetailImageCell.self, forCellWithReuseIdentifier: DetailImageCell.reuseIdentifier)
        
        return view
    }()
    
    lazy var tableView: UITableView = {
        let view = UITableView()

        Section.allCases.forEach { section in
            section.typeOfCell.forEach { type in
                view.register(type, forCellReuseIdentifier: type.reuseIdentifier)
            }
        }
        
        view.tableHeaderView = imageHeaderView
        
        return view
    }()
    
    override func addSubviews() {
        addSubview(tableView)
    }
    
    override func addConstraint() {
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
    }
    
    
}
