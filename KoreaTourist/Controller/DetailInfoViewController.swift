//
//  DetailInfoViewController.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2022/11/03.
//

import UIKit

class DetailInfoViewController: BaseViewController, SubInfoElementController {
    
    let place: CommonPlaceInfo
    
    var detail: DetailInformation?
    
    let elementView = UITableView(frame: .zero, style: .plain).then {
        $0.separatorInset = .zero
    }
    
    var dataSource: UITableViewDiffableDataSource<Int, Item>!
    
    override func loadView() {
        view = elementView
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureDetailView()
        fetchDetailInfo()
        
    }

    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        print(elementView.contentSize.height)
//    }
    
    func fetchDetailInfo() {
        
        realm.fetchPlaceDetail(type: place.contentType.detailInfoType, contentId: place.contentId, contentType: place.contentType) { [weak self] in
            self?.detail = $0
            self?.updateSnapshot()
        }
        
    }
    
    func updateSnapshot() {
        
        guard let detail = detail else { return }
        
        var snapshot = NSDiffableDataSourceSnapshot<Int, Item>()
        
        let sections = detail.detailInfoList
            .filter { $0.isValidate == true }
        
        for i in 0..<sections.count {
            let item = Item(info: sections[i])
            
            snapshot.appendSections([i])
            snapshot.appendItems([item], toSection: i)
        }
    
        dataSource.applySnapshotUsingReloadData(snapshot)
        
    }
    
    func configureDetailView() {
        
//        elementView.isScrollEnabled = false
        elementView.allowsSelection = false
        
        elementView.register(DetailInfoCell.self, forCellReuseIdentifier: DetailInfoCell.reuseIdentifier)
        
        dataSource = UITableViewDiffableDataSource(tableView: elementView, cellProvider: { tableView, indexPath, itemIdentifier in
                        
            if let cell = tableView.dequeueReusableCell(withIdentifier: DetailInfoCell.reuseIdentifier, for: indexPath) as? DetailInfoCell {
                
                cell.inputData(data: itemIdentifier.info)
                
                return cell
                
            }
                
            
            return UITableViewCell()
            
        })
        
    }
    
    init(place: CommonPlaceInfo) {
        self.place = place
        super.init()
    }
    

}


extension DetailInfoViewController {
    
    struct Item: Hashable {
        
        static func == (lhs: DetailInfoViewController.Item, rhs: DetailInfoViewController.Item) -> Bool {
            lhs.info.title == rhs.info.title
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(info.title)
        }
        
        let info: DetailInfo
    }
    
    
}

