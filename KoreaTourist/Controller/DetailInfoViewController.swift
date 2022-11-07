//
//  DetailInfoViewController.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2022/11/03.
//

import UIKit

class DetailInfoViewController: BaseViewController, SubInfoElementController {
    
    let place: CommonPlaceInfo
    
    var detail: [DetailInfo] = [] {
        didSet { updateSnapshot() }
    }
    
    let elementView = UITableView(frame: .zero, style: .grouped)
    
    var dataSource: UITableViewDiffableDataSource<Int, Item>!
    
    override func loadView() {
        view = elementView
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureDetailView()
        fetchDetailInfo()
        
    }
    
    func fetchDetailInfo() {
        
        realm.fetchPlaceDetail(type: place.contentType.detailInfoType, contentId: place.contentId, contentType: place.contentType) { [weak self] in
            self?.detail = $0.detailInfoList.filter{ data in
                data.isValidate == true
            }
        }
        
    }
    
    
    func updateSnapshot() {
        
        var snapshot = NSDiffableDataSourceSnapshot<Int, Item>()
        
        for i in 0..<detail.count {
            let item = Item(info: detail[i])
            
            snapshot.appendSections([i])
            snapshot.appendItems([item], toSection: i)
        }
    
        dataSource.applySnapshotUsingReloadData(snapshot)
        
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
    
    func configureDetailView() {
        
        elementView.tableFooterView = UIView().then {
            $0.frame = CGRect(origin: .zero, size: CGSize(width: CGFloat.leastNormalMagnitude, height: CGFloat.leastNormalMagnitude))
        }
        
        elementView.tableHeaderView = UIView().then {
            $0.frame = CGRect(origin: .zero, size: CGSize(width: CGFloat.leastNormalMagnitude, height: CGFloat.leastNormalMagnitude))
        }
        
        elementView.isScrollEnabled = false
        elementView.allowsSelection = false
        elementView.separatorInset = .zero
        
        
        elementView.register(DetailInfoCell.self, forCellReuseIdentifier: DetailInfoCell.reuseIdentifier)
        
        dataSource = UITableViewDiffableDataSource(tableView: elementView, cellProvider: { tableView, indexPath, itemIdentifier in
                        
            if let cell = tableView.dequeueReusableCell(withIdentifier: DetailInfoCell.reuseIdentifier, for: indexPath) as? DetailInfoCell {
                
                cell.inputData(data: itemIdentifier.info)
                
                return cell
                
            }
                
            
            return UITableViewCell()
            
        })
        
    }
    
    
}

