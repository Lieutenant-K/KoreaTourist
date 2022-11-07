//
//  ExtraInfoController.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2022/11/04.
//

import UIKit

class ExtraInfoController: BaseViewController, SubInfoElementController {
    
    let place: CommonPlaceInfo
    
    var extra: [ExtraPlaceElement] = [] {
        didSet { updateSnapshot() }
    }
    
    let elementView = UITableView(frame: .zero, style: .grouped)
    
    var dataSource: UITableViewDiffableDataSource<Int, [ExtraPlaceElement]>!
    
    override func loadView() {
        view = elementView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureExtraView()
        fetchExtraInfo()
    }
    
    func fetchExtraInfo() {
        
        realm.fetchPlaceExtra(contentId: place.contentId, contentType: place.contentType) { [weak self] extra in
            self?.extra = extra.list.filter { element in
                element.isValidate == true
            }
        }
        
    }
    
    func updateSnapshot() {
        
        var snapshot = NSDiffableDataSourceSnapshot<Int, [ExtraPlaceElement]>()
        
        if !extra.isEmpty {
            snapshot.appendSections([0])
            snapshot.appendItems([extra])
        }
        
        dataSource.apply(snapshot)
        
    }
    
    func configureExtraView() {
        elementView.tableFooterView = UIView().then {
            $0.frame = CGRect(origin: .zero, size: CGSize(width: CGFloat.leastNormalMagnitude, height: CGFloat.leastNormalMagnitude))
        }
        
        elementView.tableHeaderView = UIView().then {
            $0.frame = CGRect(origin: .zero, size: CGSize(width: CGFloat.leastNormalMagnitude, height: CGFloat.leastNormalMagnitude))
        }
        
        elementView.isScrollEnabled = false
        elementView.register(ExtraInfoCell.self, forCellReuseIdentifier: ExtraInfoCell.reuseIdentifier)
        
        dataSource = UITableViewDiffableDataSource(tableView: elementView, cellProvider: { tableView, indexPath, itemIdentifier in
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: ExtraInfoCell.reuseIdentifier, for: indexPath) as? ExtraInfoCell {
                
                cell.inputData(data: itemIdentifier)
                
                return cell
            }
            
            return UITableViewCell()
            
        })
    
        
    }

    init(place: CommonPlaceInfo){
        self.place = place
        super.init()
    }

}

