//
//  OverviewController.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2022/11/02.
//

import UIKit

final class IntroInfoController: BaseViewController, SubInfoElementController {
    private let place: CommonPlaceInfo
    private var dataSource: UITableViewDiffableDataSource<Section, Int>!
    let elementView = UITableView(frame: .zero, style: .grouped)
    
    // MARK: - LifeCycle
    override func loadView() {
        view = elementView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureIntroView()
        fetchIntro()
    }
    
    init(place: CommonPlaceInfo){
        self.place = place
        super.init()
        dataSource = createDataSource()
    }
}

// MARK: - DataSource
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
}

// MARK: - Helper Method
extension IntroInfoController {
    private func fetchIntro() {
        realm.fetchPlaceIntro(place: place) { [weak self] in
            self?.updateSnapshot()
        }
    }
    
    private func createDataSource() -> UITableViewDiffableDataSource<Section, Int> {
        UITableViewDiffableDataSource(tableView: elementView) { [unowned self] tableView, indexPath, itemIdentifier in
            let section = Section(rawValue: indexPath.section)!
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: section.cellType.reuseIdentifier, for: indexPath) as? IntroCell, let intro = place.intro {
                cell.inputData(intro: intro)
                
                return cell
            }
            
            return UITableViewCell()
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
        elementView.tableFooterView = createView()
        elementView.tableHeaderView = createView()
        elementView.isScrollEnabled = false
        Section.allCases.forEach {
            elementView.register($0.cellType, forCellReuseIdentifier: $0.cellType.reuseIdentifier)
        }
    }
}
