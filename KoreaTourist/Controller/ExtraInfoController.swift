//
//  ExtraInfoController.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2022/11/04.
//

import UIKit

class ExtraInfoController: BaseViewController, SubInfoElementController {
    
    let place: CommonPlaceInfo
    
    var extra: ExtraPlaceInfo?
    
    let elementView = UITableView(frame: .zero, style: .grouped)
    
    var dataSource: UITableViewDiffableDataSource<Int, Int>!
    
    override func loadView() {
        view = elementView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureIntroView()
        fetchExtraInfo()
    }
    
    func fetchExtraInfo() {
        
        realm.fetchPlaceExtra(contentId: place.contentId, contentType: place.contentType) { [weak self] extra in
            self?.extra = extra
            self?.updateSnapshot()
        }
        
    }
    
    func updateSnapshot() {
        
        guard let _ = extra else { return }
        
        var snapshot = NSDiffableDataSourceSnapshot<Int, Int>()
        snapshot.appendSections([0])
        snapshot.appendItems([0])
        
        dataSource.apply(snapshot)
        
    }
    
    func configureIntroView() {
        
        elementView.isScrollEnabled = false
        elementView.register(ExtraInfoCell.self, forCellReuseIdentifier: ExtraInfoCell.reuseIdentifier)
        
        dataSource = UITableViewDiffableDataSource(tableView: elementView, cellProvider: { [unowned self] tableView, indexPath, itemIdentifier in
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: ExtraInfoCell.reuseIdentifier, for: indexPath) as? ExtraInfoCell, let extra {
                
                cell.inputData(data: extra.list)
                
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

