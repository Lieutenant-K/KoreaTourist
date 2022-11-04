//
//  DetailInfoViewController.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2022/11/03.
//

import UIKit

class DetailInfoViewController: BaseViewController, SubInfoElementController {
    
    let place: DetailInformation
    
    let elementView = UITableView(frame: .zero, style: .grouped)
    
    var dataSource: UITableViewDiffableDataSource<Int, Int>!
    
    override func loadView() {
        view = elementView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureDetailView()
        
    }

    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        print(elementView.contentSize.height)
//    }
    
    func fetchDetailInfo() {
        
        realm.fetchPlaceDetail(type: place.contentType.detailInfoType, contentId: place.contentId, contentType: place.contentType) { [weak self] in
            self?.place = $0
        }
        
    }
    
    func updateSnapshot() {
        
    }
    
    func configureDetailView() {
        
//        elementView.isScrollEnabled = false
        elementView.allowsSelection = false
        
        elementView.register(DetailInfoCell.self, forCellReuseIdentifier: DetailInfoCell.reuseIdentifier)
        
        dataSource = UITableViewDiffableDataSource(tableView: elementView, cellProvider: { tableView, indexPath, itemIdentifier in
                        
            let section = Section(rawValue: indexPath.section)!
            
            let cell = tableView.dequeueReusableCell(withIdentifier: DetailInfoCell.reuseIdentifier, for: indexPath)
            
            return cell
            
        })
        
        var snapshot = NSDiffableDataSourceSnapshot<Int, Int>()
        var count = 0
        Section.allCases.forEach {
            snapshot.appendSections([$0])
            snapshot.appendItems([count], toSection: $0)
            count += 1
        }
        
        dataSource.apply(snapshot)
        
    }
    
    init(place: CommonPlaceInfo) {
        self.place = place
        super.init()
    }
    

}

extension DetailInfoViewController {
    
    enum Section: Int, CaseIterable {
        
        case time, event, service
        case culture1, culture2
        case event1, event2
        
        var contentType: ContentType {
            switch self {
            case .time, .event, .service:
                return .tour
            case .culture1, .culture2:
                return .culture
            case .event1, .event2:
                return .event
            }
        }
        
    }
    
    
}
