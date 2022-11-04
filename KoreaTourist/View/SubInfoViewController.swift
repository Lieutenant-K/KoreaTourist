//
//  SubInfoViewController.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2022/11/04.
//

import UIKit

class SubInfoViewController: BaseViewController {
    
    var place: CommonPlaceInfo!
    
    /*
    let introController = IntroInfoController()
    let detailController = DetailInfoViewController()
    let extraController = ExtraInfoController()
    */
    
    lazy var viewControllers: [SubInfoElementController] = [
        IntroInfoController(place: place),
        DetailInfoViewController(),
        ExtraInfoController()
    ]
    
    let subInfoView = SubInfoView()

    override func loadView() {
        view = subInfoView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let place = realm.loadPlaceInfo(infoType: CommonPlaceInfo.self, contentId: 2373206) {
            self.place = place
        }
        
        addChileVC()
        configureButtonAction()
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let vc = viewControllers.first else { return }
        
        subInfoView.contentView.snp.updateConstraints { make in
            make.height.equalTo(vc.elementView.contentSize.height)
        }
        
        subInfoView.contentView.bringSubviewToFront(vc.view)
        
    }
    
    private func configureButtonAction() {
        
        subInfoView.buttons.forEach {
            $0.addTarget(self, action: #selector(touchButton(_:)), for: .touchUpInside)
        }
        
    }
    
    private func addChileVC() {
        
        viewControllers.forEach {
            
            addChild($0)
            subInfoView.contentView.addSubview($0.view)
            $0.view.snp.makeConstraints { $0.edges.equalToSuperview() }
            $0.didMove(toParent: self)
            $0.elementView.delegate = self
            
        }
        
    }
    
    @objc func touchButton(_ sender: UIButton) {
        
        let vc = viewControllers[sender.tag]
        
        subInfoView.contentView.bringSubviewToFront(vc.view)
        
        subInfoView.contentView.snp.updateConstraints { make in
            make.height.equalTo(vc.elementView.contentSize.height)
        }
        
    }
    
    /*
    init(place: CommonPlaceInfo) {
        self.place = place
        super.init()
    }
    */


}

extension SubInfoViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        
        viewControllers.forEach {
            if let cell = tableView.cellForRow(at: indexPath) as? ExpandableCell, $0.elementView == tableView {
                
                cell.isExpand.toggle()
                $0.updateSnapshot()
                subInfoView.contentView.snp.updateConstraints { make in
                    make.height.equalTo(tableView.contentSize.height)
                }
                
            }
        }
        
        return nil
    }
    
}
