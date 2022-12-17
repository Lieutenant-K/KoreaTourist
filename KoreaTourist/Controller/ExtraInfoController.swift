//
//  ExtraInfoController.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2022/11/04.
//

import UIKit

final class ExtraInfoController: BaseViewController, SubInfoElementController {
    let place: CommonPlaceInfo
    let elementView = UITableView(frame: .zero, style: .grouped)
    var dataSource: UITableViewDiffableDataSource<Int, [ExtraPlaceElement]>!
    var extra: [ExtraPlaceElement] = [] {
        didSet { updateSnapshot() }
    }
    
    init(place: CommonPlaceInfo){
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
        configureExtraView()
        fetchExtraInfo()
    }
}

// MARK: - DataSource
extension ExtraInfoController {
    func updateSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, [ExtraPlaceElement]>()
        
        if !extra.isEmpty {
            snapshot.appendSections([0])
            snapshot.appendItems([extra])
        }
        
        dataSource.applySnapshotUsingReloadData(snapshot)
    }
}

// MARK: - Helper Method
extension ExtraInfoController {
    private func fetchExtraInfo() {
        realm.fetchPlaceExtra(contentId: place.contentId, contentType: place.contentType) { [weak self] extra in
            self?.extra = extra.list.filter { element in
                element.isValidate == true
            }
        }
    }
    
    private func createDataSource() -> UITableViewDiffableDataSource<Int, [ExtraPlaceElement]> {
        UITableViewDiffableDataSource(tableView: elementView) { tableView, indexPath, itemIdentifier in
            if let cell = tableView.dequeueReusableCell(withIdentifier: ExtraInfoCell.reuseIdentifier, for: indexPath) as? ExtraInfoCell {
                cell.inputData(data: itemIdentifier)
                
                return cell
            }
            return UITableViewCell()
        }
    }
    
    private func configureExtraView() {
        elementView.tableFooterView = createView()
        elementView.tableHeaderView = createView()
        elementView.isScrollEnabled = false
        elementView.register(ExtraInfoCell.self, forCellReuseIdentifier: ExtraInfoCell.reuseIdentifier)
    }
}
