//
//  OverviewController.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2022/11/02.
//

import UIKit

class IntroInfoController: BaseViewController {
    
    let introView = UITableView(frame: .zero, style: .grouped)
    
    var dataSource: UITableViewDiffableDataSource<Section, Int>!
    
    override func loadView() {
        view = introView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureIntroView()
        
    }
    
    func configureIntroView() {
        
        introView.isScrollEnabled = false
        
        Section.allCases.forEach {
            introView.register($0.cellType, forCellReuseIdentifier: $0.cellType.reuseIdentifier)
        }
        
        dataSource = UITableViewDiffableDataSource(tableView: introView, cellProvider: { tableView, indexPath, itemIdentifier in
            
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

extension IntroInfoController {
    
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
