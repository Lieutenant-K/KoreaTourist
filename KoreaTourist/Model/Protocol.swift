//
//  Protocol.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2022/12/18.
//

import UIKit
import RealmSwift

typealias Information = Object & Codable

protocol DetailInformation: Information {
    var detailInfoList: [DetailInfo] { get }
}

protocol DetailInfo {
    var iconImage: UIImage? { get }
    var title: String { get }
    var contentList: [(String, String)] { get }
    var isValidate: Bool { get }
}

protocol SubInfoElementController: UIViewController {
    var elementView: UITableView { get }
    
    func updateSnapshot()
}

extension SubInfoElementController {
    func createView() -> UIView {
        let view = UIView()
        view.frame = CGRect(origin: .zero, size: CGSize(width: CGFloat.leastNormalMagnitude, height: CGFloat.leastNormalMagnitude))
        
        return view
    }
}

// MARK: - Cell
protocol ExpandableCell: UITableViewCell {
    var arrowImage: UIImageView { get }
    var isExpand: Bool { get set }
}

protocol IntroCell: UITableViewCell {
    func inputData(intro: Intro)
}
