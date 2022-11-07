//
//  SubInfoViewController.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2022/11/04.
//

import UIKit

class SubInfoViewController: BaseViewController {
    
    let place: CommonPlaceInfo
    
    /*
    let introController = IntroInfoController()
    let detailController = DetailInfoViewController()
    let extraController = ExtraInfoController()
    */
    
    let viewControllers: [SubInfoElementController]
    
    let subInfoView = SubInfoView()

    override func loadView() {
        view = subInfoView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /*
        if let place = realm.loadPlaceInfo(infoType: CommonPlaceInfo.self, contentId: 2373206) {
            self.place = place
        }
        */
        
        addChileVC()
        configureButtonAction()
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        subInfoView.buttons.forEach {
            $0.layer.addBorderLine(color: .separator, edge: [.bottom], width: 1.5)
            if $0 == subInfoView.buttons.first {
                touchButton($0)
            }
        }
        
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
        
        subInfoView.buttons.forEach {
            $0.isSelected = $0 == sender
        }
        
        subInfoView.contentView.bringSubviewToFront(vc.view)
        
        subInfoView.contentView.snp.updateConstraints { make in
            make.height.equalTo(vc.elementView.contentSize.height)
        }
        
    }
    
    
    init(place: CommonPlaceInfo) {
        self.place = place
        self.viewControllers = [
            IntroInfoController(place: place),
            DetailInfoViewController(place: place),
            ExtraInfoController(place: place)
        ]
        super.init()
    }
    


}

extension SubInfoViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
    
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
