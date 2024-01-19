//
//  MockSettingViewController.swift
//  KoreaTourist
//
//  Created by 김윤수 on 1/18/24.
//

import UIKit
import Then
import Combine

final class MockSettingViewController: UIViewController {
    typealias Item = SettingViewModel.Item
    
    private lazy var listCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout()).then {
        let config = UICollectionLayoutListConfiguration(appearance: .plain)
        $0.collectionViewLayout = UICollectionViewCompositionalLayout.list(using: config)
        $0.delegate = self
    }
    
    private var dataSource: UICollectionViewDiffableDataSource<Int, Item>!
    private var cancellables = Set<AnyCancellable>()
    private let viewModel: SettingViewModel
    private let didSelectItemAtEvent = PassthroughSubject<Item, Never>()
    
    init(viewModel: SettingViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureSubviews()
        self.configureCollectionView()
        self.configureNavigationItem()
        self.binding()
    }
    
    private func binding() {
        let input = SettingViewModel.Input(
            viewDidLoadEvent: Just(()).eraseToAnyPublisher(),
            didSelectItemAtEvent: self.didSelectItemAtEvent.eraseToAnyPublisher()
        )
        let output = self.viewModel.transform(input: input, cancellables: &self.cancellables)
        
        output.items
            .withUnretained(self)
            .sink {
                $0.updateSnapshot(items: $1)
            }
            .store(in: &self.cancellables)
        
        output.alertTitleAndMessage
            .withUnretained(self)
            .sink {
                $0.showAlert(title: $1.title, message: $1.message)
            }
            .store(in: &self.cancellables)
    }
}

// MARK: - Helper Method
extension MockSettingViewController {
    private func updateSnapshot(items: [Item]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, Item>()
        snapshot.appendSections([0])
        snapshot.appendItems(items)
        self.dataSource.apply(snapshot)
    }
    
    private func configureNavigationItem() {
        self.title = "설정"
        self.navigationItem.largeTitleDisplayMode = .never
    }
    
    private func configureSubviews() {
        self.view.backgroundColor = .systemBackground
        self.view.addSubview(self.listCollectionView)
        
        self.listCollectionView.snp.makeConstraints { $0.edges.equalTo(self.view.safeAreaLayoutGuide)
        }
    }
    
    private func configureCollectionView() {
        let cellRegistration: UICollectionView.CellRegistration<UICollectionViewListCell, Item> = UICollectionView.CellRegistration { cell, indexPath, itemIdentifier in
            
            var config = UIListContentConfiguration.valueCell()
            config.text = itemIdentifier.title
            config.prefersSideBySideTextAndSecondaryText = false
            config.secondaryText = if case .version = itemIdentifier { "1.1" } else { nil }
            cell.accessories = if case .version = itemIdentifier { [.disclosureIndicator()] } else { [] }
            cell.contentConfiguration = config
        }
        
        self.dataSource = UICollectionViewDiffableDataSource(collectionView: self.listCollectionView) { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
            
            return cell
        }
    }
}

// MARK: - CollectionView Delegate
extension MockSettingViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = self.dataSource.snapshot(for: 0).items[indexPath.row]
        self.didSelectItemAtEvent.send(item)
    }
}
