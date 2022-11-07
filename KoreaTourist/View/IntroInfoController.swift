//
//  OverviewController.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2022/11/02.
//

import UIKit

final class IntroInfoController: BaseViewController, SubInfoElementController {
    
    private let place: CommonPlaceInfo
    
    let elementView = UITableView(frame: .zero, style: .grouped)
    
    private var dataSource: UITableViewDiffableDataSource<Section, Int>!
    
    override func loadView() {
        view = elementView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureIntroView()
        fetchIntro()
        
    }
    
    private func fetchIntro() {
        
        realm.fetchPlaceIntro(place: place) { [weak self] in
            self?.updateSnapshot()
        }
        
    }
    
    func updateSnapshot() {
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Int>()
        
        let sections = checkValidatation()
        
        var count = 0
        
        sections.forEach {
            snapshot.appendSections([$0])
            snapshot.appendItems([count], toSection: $0)
            count += 1
        }
    
        dataSource.applySnapshotUsingReloadData(snapshot)
        
    }
    
    init(place: CommonPlaceInfo){
        self.place = place
        super.init()
    }

    

}

extension IntroInfoController {
    
    enum Section: Int, CaseIterable {
        
        case overview, webpage
        
        var cellType: IntroCell.Type {
            switch self {
            case .overview:
                return OverviewInfoCell.self
            case .webpage:
                return WebPageInfoCell.self
            }
        }
        
    }
    
    private func checkValidatation() -> [Section] {
        
        guard let intro = place.intro else { return [] }
        
        var sections: [Section] = []
        
        if !intro.overview.isEmpty {
            sections.append(Section.overview)
        }
        if !intro.homepage.isEmpty {
            sections.append(Section.webpage)
        }
        
        return sections
    }
    
    private func configureIntroView() {
        
        elementView.tableFooterView = UIView().then {
            $0.frame = CGRect(origin: .zero, size: CGSize(width: CGFloat.leastNormalMagnitude, height: CGFloat.leastNormalMagnitude))
        }
        
        elementView.tableHeaderView = UIView().then {
            $0.frame = CGRect(origin: .zero, size: CGSize(width: CGFloat.leastNormalMagnitude, height: CGFloat.leastNormalMagnitude))
        }
        
        elementView.isScrollEnabled = false
        
        Section.allCases.forEach {
            elementView.register($0.cellType, forCellReuseIdentifier: $0.cellType.reuseIdentifier)
        }
        
        dataSource = UITableViewDiffableDataSource(tableView: elementView, cellProvider: { [unowned self] tableView, indexPath, itemIdentifier in
            
            
            let section = Section(rawValue: indexPath.section)!
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: section.cellType.reuseIdentifier, for: indexPath) as? IntroCell, let intro = place.intro {
                
                cell.inputData(intro: intro)
                
                return cell
                
            }
            
            return UITableViewCell()
            
            
        })
        
    }
    
    
}
