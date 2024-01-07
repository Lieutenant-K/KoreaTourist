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
    typealias TabMenu = PlaceDetailTabMenuViewModel.TabMenu
    typealias Section = PlaceDetailTabMenuViewModel.Section
    
    // MARK: - View
    private let containerView = UIView()
    private let tableView = UITableView()
    private let tabMenuView = TabMenuView(frame: .zero)
    
    // MARK: - Properties
    private let viewModel: PlaceDetailTabMenuViewModel
    private var cancellables = Set<AnyCancellable>()
    private let tabMenuTapEvent = PassthroughSubject<Int, Never>()
    private var dataSource: UITableViewDiffableDataSource<Int, Section>?
    private var containerHeight: Constraint?
    
    // MARK: - Initializer
    init(viewModel: PlaceDetailTabMenuViewModel) {
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
        let input = PlaceDetailTabMenuViewModel.Input(
            viewDidLoadEvent: Just(()).eraseToAnyPublisher(),
            viewDidAppearEvent: self.viewDidAppearPublisher,
            tabMenuTapEvent: self.tabMenuView.selectedButtonPublisher
        )
        let output = self.viewModel.transform(input: input, cancellables: &self.cancellables)
        
        output.selectedMenu
            .withUnretained(self)
            .sink {
                $0.updateTableViewUsing(tabMenu: $1)
            }
            .store(in: &self.cancellables)
        
        output.visibleTabMenus
            .map { $0.map { $0.title } }
            .withUnretained(self)
            .sink {
                $0.tabMenuView.addButtonWithTitle($1)
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
            self.updateTableViewWith(snapshot: snapshot)
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
    
    private func updateTableViewUsing(tabMenu: TabMenu) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, Section>()
        tabMenu.sections.enumerated().forEach { idx, section in
            snapshot.appendSections([idx])
            snapshot.appendItems([section], toSection: idx)
        }
        self.updateTableViewWith(snapshot: snapshot)
    }
    
    private func updateTableViewWith(snapshot: NSDiffableDataSourceSnapshot<Int, Section>) {
        self.containerHeight?.update(offset: CGFloat.greatestFiniteMagnitude)
        self.dataSource?.applySnapshotUsingReloadData(snapshot)
        self.tableView.layoutIfNeeded()
        self.containerHeight?.update(offset: self.tableView.contentSize.height)
    }
}

// MARK: - View Configuring Method
extension PlaceDetailTabMenuViewController {
    private func configureSubviews() {
        self.view.addSubview(self.containerView)
        self.view.addSubview(self.tabMenuView)
        self.containerView.addSubview(self.tableView)
        
        self.tabMenuView.snp.makeConstraints {
            $0.leading.top.trailing.equalTo(self.view.safeAreaLayoutGuide)
            $0.height.equalTo(40)
        }
        
        self.containerView.snp.makeConstraints {
            $0.top.equalTo(self.tabMenuView.snp.bottom)
            $0.leading.bottom.trailing.equalToSuperview()
            self.containerHeight = $0.height.equalTo(1000).priority(.high).constraint
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
