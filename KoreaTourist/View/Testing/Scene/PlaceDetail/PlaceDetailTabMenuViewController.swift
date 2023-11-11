//
//  PlaceDetailTabViewController.swift
//  KoreaTourist
//
//  Created by 김윤수 on 10/21/23.
//

import UIKit
import Combine

import SnapKit
import Then

final class PlaceDetailTabMenuViewController: UIViewController {
    typealias TabMenu = PlaceDetailTapMenuViewModel.TabMenu
    typealias Section = PlaceDetailTapMenuViewModel.Section
    
    // MARK: - View
    //    private var tabMenuButtons: [UIButton] = []
    private let containerView = UIView()
    private let tableView = UITableView()
    private let tabMenuButtonStackView = UIStackView().then {
        $0.alignment = .fill
        $0.distribution = .fillEqually
        $0.axis = .horizontal
        $0.spacing = 0
    }
    
    // MARK: - Properties
    private let viewModel: PlaceDetailTapMenuViewModel
    private var cancellables = Set<AnyCancellable>()
    private let tabMenuTapEvent = PassthroughSubject<Int, Never>()
    private var dataSource: UITableViewDiffableDataSource<Int, Section>?
    
    // MARK: - Initializer
    init(viewModel: PlaceDetailTapMenuViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureSubviews()
        self.configureTableView()
        self.bindViewModel()
    }
    
    func bindViewModel() {
        let input = PlaceDetailTapMenuViewModel.Input(
            viewDidLoadEvent: Just(()).eraseToAnyPublisher(),
            tabMenuTapEvent: self.tabMenuTapEvent.eraseToAnyPublisher()
        )
        let output = self.viewModel.transform(input: input, cancellables: &self.cancellables)
        
        output.visibleTabMenus
            .withUnretained(self)
            .sink {
                $0.addTabMenuButton(using: $1)
            }
            .store(in: &self.cancellables)
        
        output.selectedMenu
            .withUnretained(self)
            .sink {
                $0.updateSnapshot(tabMenu: $1)
            }
            .store(in: &self.cancellables)
    }
}

// MARK: - TableView Delegate Method
extension PlaceDetailTabMenuViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        .leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if let cell = tableView.cellForRow(at: indexPath) as? ExpandableCell, let snapshot = self.dataSource?.snapshot() {
            cell.isExpand.toggle()
            self.containerView.snp.updateConstraints {
                $0.height.equalTo(tableView.contentSize.height).priority(.high)
            }
            self.dataSource?.applySnapshotUsingReloadData(snapshot)
        }
        
        return nil
    }
    
    private func tableViewDataSource() -> UITableViewDiffableDataSource<Int, Section> {
        UITableViewDiffableDataSource(tableView: self.tableView) { tableView, indexPath, itemIdentifier in
            
            switch itemIdentifier {
            case let .webpage(intro):
                if let cell = tableView.dequeueReusableCell(withIdentifier: WebPageInfoCell.reuseIdentifier, for: indexPath) as? WebPageInfoCell {
                    cell.inputData(intro: intro)
                    return cell
                }
            case let .overview(intro):
                if let cell = tableView.dequeueReusableCell(withIdentifier: OverviewInfoCell.reuseIdentifier, for: indexPath) as? OverviewInfoCell {
                    cell.inputData(intro: intro)
                    return cell
                }
            case let .detailInfo(detail):
                if let cell = tableView.dequeueReusableCell(withIdentifier: DetailInfoCell.reuseIdentifier, for: indexPath) as? DetailInfoCell {
                    cell.inputData(data: detail)
                    return cell
                }
            case let .extra(array):
                if let cell = tableView.dequeueReusableCell(withIdentifier: ExtraInfoCell.reuseIdentifier, for: indexPath) as? ExtraInfoCell {
                    cell.inputData(data: array)
                    return cell
                }
            }
            
            return UITableViewCell()
        }
    }
    
    private func updateSnapshot(tabMenu: TabMenu) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, Section>()
        tabMenu.sections.enumerated().forEach { idx, section in
            snapshot.appendSections([idx])
            snapshot.appendItems([section], toSection: idx)
        }
        self.dataSource?.applySnapshotUsingReloadData(snapshot)
    }
}

// MARK: - Helper Method
extension PlaceDetailTabMenuViewController {
    private func addTabMenuButton(using tabMenus: [TabMenu]) {
        
        tabMenus.enumerated().forEach { (idx, tabMenu) in
            let button = UIButton(type: .custom)
            button.tag = idx
            button.configurationUpdateHandler = self.tabMenuButtonUpdateHandler(title: tabMenu.title)
            button.tapPublisher.map { button.tag }
                .withUnretained(self)
                .sink { $0.tabMenuTapEvent.send($1) }
                .store(in: &self.cancellables)
            
            //            self.tabMenuButtons.append(button)
            self.tabMenuButtonStackView.addArrangedSubview(button)
        }
    }
    
    private func tabMenuButtonUpdateHandler(title: String) -> UIButton.ConfigurationUpdateHandler {
        return { button in
            var color: UIColor
            var font: UIFont
            
            switch button.state {
            case .selected:
                color = .label
                font = .systemFont(ofSize: 18, weight: .semibold)
                button.setBorderLine()
            default:
                color = .secondaryLabel
                font = .systemFont(ofSize: 18, weight: .medium)
                button.setBorderLine()
            }
            
            let container = AttributeContainer([.font:font, .foregroundColor:color])
            let attrTitle = AttributedString(title, attributes: container)
            
            var config = UIButton.Configuration.plain()
            config.attributedTitle = attrTitle
            config.background.cornerRadius = 0
            config.background.backgroundColor = .clear
            
            button.configuration = config
        }
    }
}

// MARK: - View Configuring Method
extension PlaceDetailTabMenuViewController {
    private func configureSubviews() {
        self.view.addSubview(self.containerView)
        self.view.addSubview(self.tabMenuButtonStackView)
        self.containerView.addSubview(self.tableView)
        
        self.tabMenuButtonStackView.snp.makeConstraints {
            $0.leading.top.trailing.equalTo(self.view.safeAreaLayoutGuide)
            $0.height.equalTo(48)
        }
        
        self.containerView.snp.makeConstraints {
            $0.top.equalTo(self.tabMenuButtonStackView.snp.bottom)
            $0.leading.bottom.trailing.equalToSuperview()
            $0.height.equalTo(1000).priority(.high)
        }
        
        self.tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func configureTableView() {
        self.dataSource = self.tableViewDataSource()
        self.tableView.delegate = self
        self.tableView.tableFooterView = self.emptyView()
        self.tableView.tableHeaderView = self.emptyView()
        self.tableView.isScrollEnabled = false
        //        self.tableView.allowsSelection = false
        self.tableView.separatorInset = .zero
        self.tableView.register(DetailInfoCell.self, forCellReuseIdentifier: DetailInfoCell.reuseIdentifier)
        self.tableView.register(ExtraInfoCell.self, forCellReuseIdentifier: ExtraInfoCell.reuseIdentifier)
        self.tableView.register(WebPageInfoCell.self, forCellReuseIdentifier: WebPageInfoCell.reuseIdentifier)
        self.tableView.register(OverviewInfoCell.self, forCellReuseIdentifier: OverviewInfoCell.reuseIdentifier)
    }
    
    private func emptyView() -> UIView {
        let view = UIView()
        view.frame = CGRect(origin: .zero, size: CGSize(width: CGFloat.leastNormalMagnitude, height: CGFloat.leastNormalMagnitude))
        
        return view
    }
}
