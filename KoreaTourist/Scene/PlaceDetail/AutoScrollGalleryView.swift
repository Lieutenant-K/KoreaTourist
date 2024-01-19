//
//  AutoScrollGalleryView.swift
//  KoreaTourist
//
//  Created by 김윤수 on 11/12/23.
//

import UIKit

import Then
import SnapKit
import Kingfisher

final class AutoScrollGalleryView: UIView {
    // MARK: - Views
    let pageLabel = BasePaddingLabel(padding: UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 10)).then {
        $0.font = .systemFont(ofSize: 14, weight: .medium)
        $0.layer.cornerRadius = 14
        $0.textColor = .white
        $0.backgroundColor = .black.withAlphaComponent(0.6)
        $0.clipsToBounds = true
        $0.textAlignment = .center
        $0.numberOfLines = 1
    }
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.collectionViewLayout()).then {
        $0.showsHorizontalScrollIndicator = false
        $0.isPagingEnabled = true
        $0.backgroundColor = .systemGroupedBackground
        $0.delegate = self
    }
    
    // MARK: - Properties & Method
    private var images: [PlaceImage] = []
    private var dataSource: UICollectionViewDiffableDataSource<Int, Int>!
    private var autoScrollTimer = Timer()
    
    init() {
        super.init(frame: .zero)
        self.configureSubviews()
        self.configureCollectionViewDataSource()
        self.isHidden = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateImages(with images: [PlaceImage]) {
        self.images = images + images + images
        self.isHidden = images.count > 0 ? false : true
        self.updateSnapshot()
        self.resetScrollPos()
        self.activateAutoScrollTimer()
    }
}

// MARK: - Gallery Image Update Method
extension AutoScrollGalleryView: UICollectionViewDelegate {
    var originCount: Int { self.images.count / 3 }
    
    private func updateSnapshot() {
        let count = self.images.count
        
        var snapshot = NSDiffableDataSourceSnapshot<Int, Int>()
        snapshot.appendSections([0])
        snapshot.appendItems([Int].init(0..<count))
        
        self.dataSource.apply(snapshot)
    }
    
    private func activateAutoScrollTimer() {
        if self.originCount < 2 { return }
        
        self.autoScrollTimer = Timer.scheduledTimer(withTimeInterval: 2.5, repeats: true) { [weak self] _ in
            guard let weakSelf = self else { return }
            
            let collectionView = weakSelf.collectionView
            let originCount = weakSelf.originCount
            
            guard let cell = collectionView.visibleCells.first, var index = collectionView.indexPath(for: cell)?.row else { return }
            
            if index == originCount*2-1  {
                index = originCount-1
                collectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: .centeredHorizontally, animated: false)
            }
            
            collectionView.scrollToItem(at: IndexPath(row: index+1, section: 0), at: .centeredHorizontally, animated: true)
        }
        
        RunLoop.main.add(self.autoScrollTimer, forMode: .common)
    }
    
    private func resetScrollPos() {
        guard let index = dataSource.indexPath(for: self.originCount) else {
            return
        }
        
        self.collectionView.scrollToItem(at: index, at: .centeredHorizontally, animated: false)
        self.pageLabel.text = "1 / \(self.originCount)"
    }
}

// MARK: - ScrollView Delegate Method
extension AutoScrollGalleryView {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let width = self.collectionView.frame.width
        let offset = scrollView.contentOffset.x
        let pageIndex = Int((offset / width).rounded()) % self.originCount
        
        self.pageLabel.text  = "\(pageIndex+1) / \(self.originCount)"
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        autoScrollTimer.invalidate()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let collectionView = self.collectionView
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        
        guard var index = collectionView.indexPathForItem(at: visiblePoint)?.row else { return }
        
        if index == self.originCount * 2 {
            index = self.originCount
        } else if index == self.originCount - 1 {
            index = 2 * self.originCount - 1
        }
        
        collectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: .centeredHorizontally, animated: false)
        
        if !self.autoScrollTimer.isValid {
            self.activateAutoScrollTimer()
        }
        
        scrollView.isScrollEnabled = true
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let offset = targetContentOffset.pointee.x
        let width = scrollView.bounds.width
        let count = Double(self.originCount)
        
        if offset == 2*count*width || offset == (count-1)*width {
            print("🥹🥹 감속을 완료해야해! 🥹🥹")
            scrollView.isScrollEnabled = false
        }
    }
}

// MARK: - Helper Method
extension AutoScrollGalleryView {
    private func collectionViewLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.scrollDirection = .horizontal
        config.contentInsetsReference = .none
        
        let layout = UICollectionViewCompositionalLayout(section: section, configuration: config)
        
        return layout
    }
    
    private func configureCollectionViewDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<DetailImageCell, PlaceImage> { cell, indexPath, itemIdentifier in
            let url = URL(string: itemIdentifier.originalImage)
            
            cell.imageView.kf.indicatorType = .activity
            cell.imageView.kf.setImage(with: url ,options: [.transition(.fade(0.5))])
        }
        
        self.dataSource = UICollectionViewDiffableDataSource(collectionView: self.collectionView, cellProvider: { [unowned self] collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: self.images[itemIdentifier])
            
            return cell
        })
    }
    
    private func configureSubviews() {
        [self.collectionView, self.pageLabel].forEach {
            self.addSubview($0)
        }
        
        self.collectionView.snp.makeConstraints {
            $0.leading.trailing.bottom.top.equalToSuperview()
            $0.height.equalTo(self.collectionView.snp.width).multipliedBy(0.75)
        }
        
        self.pageLabel.snp.makeConstraints {
            $0.bottom.equalTo(-12)
            $0.centerX.equalToSuperview()
        }
    }
}

