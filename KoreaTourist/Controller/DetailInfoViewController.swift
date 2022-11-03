//
//  DetailInfoViewController.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2022/11/03.
//

import UIKit

class DetailInfoViewController: BaseViewController {
    
    let detailView = UITableView(frame: .zero, style: .grouped)
    
    var dataSource: UITableViewDiffableDataSource<Section, Int>!
    
    override func loadView() {
        view = detailView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureDetailView()
        
    }
    
    func configureDetailView() {
        
        detailView.isScrollEnabled = false
        
        Section.allCases.forEach {
            detailView.register($0.cellType, forCellReuseIdentifier: $0.cellType.reuseIdentifier)
        }
        
        dataSource = UITableViewDiffableDataSource(tableView: detailView, cellProvider: { tableView, indexPath, itemIdentifier in
            
            var cell: UITableViewCell
            
            let section = Section(rawValue: indexPath.section)!
            
            switch section {
            case .overview:
                cell = tableView.dequeueReusableCell(withIdentifier: section.cellType.reuseIdentifier, for: indexPath)
            case .webpage:
                cell = tableView.dequeueReusableCell(withIdentifier: section.cellType.reuseIdentifier, for: indexPath)
            }
            
            return cell
            
        })
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Int>()
        snapshot.appendSections([Section.overview, Section.webpage])
        snapshot.appendItems([0], toSection: Section.overview)
        snapshot.appendItems([1], toSection: Section.webpage)
        
        dataSource.apply(snapshot)
        
    }

    

}

extension DetailInfoViewController {
    
    enum Section: Int, CaseIterable {
        
        case overview, webpage
        
        var cellType: UITableViewCell.Type {
            switch self {
            case .overview:
                return OverviewInfoCell.self
            case .webpage:
                return WebPageInfoCell.self
            }
        }
        
    }
    
    
}
