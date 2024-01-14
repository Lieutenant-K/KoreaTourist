//
//  MyCollectionViewController.swift
//  KoreaTourist
//
//  Created by 김윤수 on 1/4/24.
//

import UIKit
import Combine

import SnapKit
import Then

final class MyCollectionViewController: UIViewController {
    // MARK: - Views
    private lazy var placeCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
        $0.collectionViewLayout = self.collectionViewLayout()
        $0.backgroundView = self.emptyView
        $0.delegate = self
    }
    private let emptyView = UIView().then {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        label.text = "아직 발견된 장소가 없어요 :("
        label.textColor = .placeholderText
        label.textAlignment = .center
        
        $0.addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    private let closeButton = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: nil, action: nil)
    private let settingButton = UIBarButtonItem(image: UIImage(systemName: "gearshape.fill"), style: .plain, target: nil, action: nil)
    private let worldMapButton: UIBarButtonItem = {
        let button = UIButton(type: .system)
        button.setImage(.map, for: .normal)
        button.snp.makeConstraints {
            $0.size.equalTo(27)
        }
        return UIBarButtonItem(customView: button)
    }()
    private weak var collectionHeaderView: UICollectionReusableView?
    
    // MARK: - Properties
    private var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, Item>!
    private let viewModel: MyCollectionViewModel
    private var cancellables = Set<AnyCancellable>()
    private let didSelectItemAtEvent = PassthroughSubject<Item, Never>()
    
    init(viewModel: MyCollectionViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureSubviews()
        self.configureCollectionViewDataSource()
        self.configureNavigationItem()
        self.bindViewModel()
    }
    
    private func bindViewModel() {
        let input = MyCollectionViewModel.Input(
            viewDidLoadEvent: Just(()).eraseToAnyPublisher(),
            closeButtonTapEvent: self.closeButton.tapPublisher,
            settingButtonTapEvent: self.settingButton.tapPublisher,
            worldMapButtonTapEvent: self.worldMapButton.tapPublisher,
            didSelectItemAtEvent: self.didSelectItemAtEvent.eraseToAnyPublisher()
        )
        let output = self.viewModel.transform(input: input, cancellables: &self.cancellables)
        
        output.areaCodeList
            .map { $0.map{ Item.region($0) } }
            .withUnretained(self)
            .sink {
                $0.updateSnapshot(section: .region, items: $1)
            }
            .store(in: &self.cancellables)
        
        output.collectedPlaceList
            .map { $0.filter { $0.isDiscovered } }
            .map { $0.map { Item.place($0) } }
            .withUnretained(self)
            .sink {
                $0.updateSnapshot(section: .place, items: $1)
                $0.emptyView.isHidden = $1.isEmpty ? false : true
            }
            .store(in: &self.cancellables)
        
        output.collectedPlaceList
            .withUnretained(self)
            .sink {
                $0.updateCollectedPlaceCount(placeList: $1)
            }
            .store(in: &self.cancellables)
    }
}

// MARK: - Helper Method
extension MyCollectionViewController {
    private func updateSnapshot(section: SectionLayoutKind, items: [Item]) {
        var currentSnapshot = self.dataSource.snapshot(for: section)
        switch section {
        case .region:
            currentSnapshot.append(items)
        case .place:
            currentSnapshot.deleteAll()
            currentSnapshot.append(items)
        }
        self.dataSource.apply(currentSnapshot, to: section)
    }
    
    private func updateCollectedPlaceCount(placeList: [CommonPlaceInfo]) {
        let collectedCnt = placeList.count
        let discoveredCnt = placeList.filter { $0.isDiscovered }.count
        
        let headerRegistration = UICollectionView.SupplementaryRegistration<MyCollectionHeaderView>(elementKind: self.headerElementKind) { supplementaryView, _, _ in
            supplementaryView.updateLabel(discoveredCnt: discoveredCnt, collectedCnt: collectedCnt)
        }
        
        self.dataSource.supplementaryViewProvider = { [weak self] collectionView, _, indexPath in
            let view = collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
            self?.collectionHeaderView = view
            return view
        }
        
        if let view = self.collectionHeaderView as? MyCollectionHeaderView {
            view.updateLabel(discoveredCnt: discoveredCnt, collectedCnt: collectedCnt)
        }
    }
    
    private func configureSubviews() {
        self.view.addSubview(self.placeCollectionView)
        self.placeCollectionView.snp.makeConstraints {
            $0.edges.equalTo(self.view.safeAreaLayoutGuide)
        }
    }
    
    private func configureNavigationItem() {
        self.title = "나의 컬렉션"
        self.navigationItem.leftBarButtonItem = self.closeButton
        self.navigationItem.rightBarButtonItems = [self.settingButton, self.worldMapButton]
        self.navigationItem.backButtonTitle = "뒤로"
    }
}

// MARK: - CollectionView Delegate Method
extension MyCollectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let sectionKind = SectionLayoutKind(rawValue: indexPath.section) {
            let item = self.dataSource.snapshot(for: sectionKind).items[indexPath.row]
            self.didSelectItemAtEvent.send(item)
        }
    }
}

extension MyCollectionViewController {
    enum SectionLayoutKind: Int, CaseIterable {
        case region, place
    }
    
    enum Item: Hashable {
        case region(AreaCode)
        case place(CommonPlaceInfo)
    }
    
    private var headerElementKind: String {
        return "header-element-kind"
    }
    
    private func configureCollectionViewDataSource() {
        let regionCategoryCellRegistration = UICollectionView.CellRegistration<AreaCategoryCell, AreaCode> { cell, indexPath, item in
            cell.label.text = item.name
        }
        
        let placeCellRegistration = UICollectionView.CellRegistration<PlaceCollectionCell, CommonPlaceInfo> { cell, indexPath, item in
            if item.isImageIncluded {
                cell.imageView.kf.setImage(with: URL(string: item.thumbnail), options: [.transition(.fade(0.5))])
                cell.imageView.contentMode = .scaleAspectFill
            } else {
                cell.imageView.image = UIImage(systemName: "photo")
                cell.imageView.contentMode = .center
            }
        }
        
        let dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, Item>(collectionView: self.placeCollectionView) { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case let .region(areaCode):
                let cell = collectionView.dequeueConfiguredReusableCell(using: regionCategoryCellRegistration, for: indexPath, item: areaCode)
                return cell
            case let .place(info):
                let cell = collectionView.dequeueConfiguredReusableCell(using: placeCellRegistration, for: indexPath, item: info)
                return cell
            }
        }
        
        self.dataSource = dataSource
        self.setEmptySnapshot(dataSource: dataSource)
    }
    
    private func setEmptySnapshot(dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, Item>) {
        var snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, Item>()
        snapshot.appendSections([.region, .place])
        snapshot.appendItems([], toSection: .region)
        snapshot.appendItems([], toSection: .place)
        
        self.dataSource.apply(snapshot)
    }
    
    private func collectionViewLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, layoutEnvironment in
            let sectionKind = SectionLayoutKind(rawValue: sectionIndex)
            
            switch sectionKind {
            case .region:
                return self?.regionItemSectionLayout()
            case .place:
                return self?.placeItemSectionLayout(layoutEnvironment: layoutEnvironment)
            default:
                return nil
            }
        }
        
        let config = UICollectionViewCompositionalLayoutConfiguration().then {
            let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(30))
            let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: size, elementKind: self.headerElementKind, alignment: .top)
            $0.boundarySupplementaryItems = [header]
        }
        
        layout.configuration = config
        
        return layout
    }
    
    private func regionItemSectionLayout() -> NSCollectionLayoutSection {
        let space: CGFloat = 4
        let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(44), heightDimension: .estimated(44))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.edgeSpacing = NSCollectionLayoutEdgeSpacing(leading: .none, top: .none, trailing: .flexible(space), bottom: .none)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = space
        section.contentInsets = NSDirectionalEdgeInsets(value: space*2)
        
        return section
    }
    
    private func placeItemSectionLayout(layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let space: CGFloat = 4
        let rate: CGFloat = layoutEnvironment.traitCollection.horizontalSizeClass == .compact ? 0.3333 : 0.2
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(rate), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(value: space)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(rate))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(value: space)
        
        return section
    }
}
