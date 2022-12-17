//
//  DetailInfoViewController.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2022/11/03.
//

import UIKit

final class DetailInfoViewController: BaseViewController, SubInfoElementController {
    let place: CommonPlaceInfo
    let elementView = UITableView(frame: .zero, style: .grouped)
    var dataSource: UITableViewDiffableDataSource<Int, Item>!
    var detail: [DetailInfo] = [] {
        didSet { updateSnapshot() }
    }
    
    init(place: CommonPlaceInfo) {
        self.place = place
        super.init()
        dataSource = createDataSource()
    }
    
    // MARK: - LifeCycle
    override func loadView() {
        view = elementView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureDetailView()
        fetchDetailInfo()
    }
}

// MARK: - DataSource
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
    
    func updateSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, Item>()
        
        detail.enumerated().forEach { i, detail in
            let item = Item(info: detail)
            
            snapshot.appendSections([i])
            snapshot.appendItems([item], toSection: i)
        }

        dataSource.applySnapshotUsingReloadData(snapshot)
    }
}

// MARK: - Helper Method
extension DetailInfoViewController {
    private func createDataSource() -> UITableViewDiffableDataSource<Int, Item> {
        UITableViewDiffableDataSource(tableView: elementView ) { tableView, indexPath, itemIdentifier in
        
            if let cell = tableView.dequeueReusableCell(withIdentifier: DetailInfoCell.reuseIdentifier, for: indexPath) as? DetailInfoCell {
                cell.inputData(data: itemIdentifier.info)
                
                return cell
            }
                
            return UITableViewCell()
        }
    }
    
    private func fetchDetailInfo() {
        realm.fetchPlaceDetail(type: place.contentType.detailInfoType, contentId: place.contentId, contentType: place.contentType) { [weak self] in
            self?.detail = $0.detailInfoList.filter{ data in
                data.isValidate == true
            }
        }
    }
    
    private func configureDetailView() {
        elementView.tableFooterView = createView()
        elementView.tableHeaderView = createView()
        elementView.isScrollEnabled = false
        elementView.allowsSelection = false
        elementView.separatorInset = .zero
        elementView.register(DetailInfoCell.self, forCellReuseIdentifier: DetailInfoCell.reuseIdentifier)
    }
}

