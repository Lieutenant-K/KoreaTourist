//
//  SubInfoViewController.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2022/11/04.
//

import UIKit
import SnapKit

final class SubInfoViewController: BaseViewController {
    let place: CommonPlaceInfo
    let viewControllers: [SubInfoElementController]
    let subInfoView = SubInfoView()
    
    init(place: CommonPlaceInfo) {
        self.place = place
        self.viewControllers = [
            IntroInfoController(place: place),
            DetailInfoViewController(place: place),
            ExtraInfoController(place: place)
        ]
        super.init()
    }
    
    // MARK: - LifeCycle
    override func loadView() {
        view = subInfoView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addObserver()
        addChileVC()
        configureButtonAction()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        resetSubInfoButtons()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        print(#function)
    }
}

// MARK: - Helper Method
extension SubInfoViewController {
    private func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(resetSubInfoButtons), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    private func configureButtonAction() {
        subInfoView.buttons.forEach {
            $0.addTarget(self, action: #selector(touchButton(_:)), for: .touchUpInside)
        }
    }
    
    private func addChileVC() {
        viewControllers.forEach { vc in
            addChild(vc)
            subInfoView.contentView.addSubview(vc.view)
            
            vc.view.snp.makeConstraints { $0.edges.equalToSuperview() }
            vc.didMove(toParent: self)
            vc.elementView.delegate = self
        }
    }
}

// MARK: - Action Method
extension SubInfoViewController {
    @objc private func resetSubInfoButtons() {
        subInfoView.buttons.forEach {
            $0.setNeedsUpdateConfiguration()
        }
        
        if let first = subInfoView.buttons.first {
            touchButton(first)
        }
    }
    
    @objc func touchButton(_ sender: UIButton) {
        let vc = viewControllers[sender.tag]
        
        subInfoView.buttons.forEach {
            $0.isSelected = $0 == sender
        }
        subInfoView.contentView.bringSubviewToFront(vc.view)
        subInfoView.contentView.snp.updateConstraints {
            $0.height.equalTo(vc.elementView.contentSize.height)
        }
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
        viewControllers.forEach { vc in
            if let cell = tableView.cellForRow(at: indexPath) as? ExpandableCell, vc.elementView == tableView {
                cell.isExpand.toggle()
                vc.updateSnapshot()
                subInfoView.contentView.snp.updateConstraints {
                    $0.height.equalTo(tableView.contentSize.height)
                }
            }
        }
        return nil
    }
    
}
