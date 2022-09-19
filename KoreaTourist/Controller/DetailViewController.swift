//
//  DetailViewController.swift
//  KakaoMap
//
//  Created by 김윤수 on 2022/09/16.
//

import UIKit
import Kingfisher
/*
struct TotalPlaceInfo {
    
    let commonInfo: CommonPlaceInfo
    var detailInfo: TourPlaceInfo?
    var extraInfo: ExtraPlaceInfo?
    var images: [DetailImage]?
    
}
*/
enum Section: Int, CaseIterable {
    
    case common = 0
    case detail = 1
    case extra = 2
    
    var typeOfCell: [BaseInfoCell.Type] {
        switch self {
        case .common:
            return [OverviewInfoCell.self, AddressInfoCell.self, LocationInfoCell.self, WebPageInfoCell.self]
        case .detail:
            return [TimeInfoCell.self, EventInfoCell.self, OtherDetailInfoCell.self]
        case .extra:
            return [ExtraInfoCell.self]
        }
    }
    
    
    var title: String {
        switch self {
        case .common:
            return "기본 정보"
        case .detail:
            return "자세한 정보"
        case .extra:
            return "추가 정보"
        }
    }
    
}

final class DetailViewController: BaseViewController {
    
    // MARK: - Properties
    
    lazy var placeInfoList: [PlaceInfo] = {
        return [commonInfo]
    }()
    
    let commonInfo: CommonPlaceInfo
    
    var detailInfo: TourPlaceInfo?
    var extraInfo: ExtraPlaceInfo?
    
    var images: [DetailImage] = []
    
    lazy var detailView: DetailView = {
        let view = DetailView()
        view.tableView.delegate = self
        view.tableView.dataSource = self
        view.imageHeaderView.collectionView.dataSource = self
        view.imageHeaderView.collectionView.delegate = self
        return view
    }()
    
    // MARK: - LifeCycle
    
    override func loadView() {
        view = detailView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        let type = commonInfo.contentType.modelType
        
        fetchDetailPlaceInfo()
        
        fetchDetailImages()
        
    }
    
    
    
    // MARK: - Method
    
    private func fetchDetailPlaceInfo() {
        
        APIManager.shared.requestDetailPlaceInfo(contentId: commonInfo.contentId, contentType: commonInfo.contentType) { [weak self] (data: TourPlaceInfo) in
            
            DispatchQueue.main.async {
                
                print("디테일 데이터 갱신")
                
                self?.detailInfo = data
                
                self?.placeInfoList.append(data)
                
                self?.detailView.tableView.reloadData()
                
                self?.fetchExtraPlaceInfo()

            }
            
        }
        
    }
    
    private func fetchExtraPlaceInfo() {
        
        APIManager.shared.requestExtraPlaceInfo(contentId: commonInfo.contentId, contentType: commonInfo.contentType) { [weak self] (data: [ExtraPlaceElement]) in
            
            DispatchQueue.main.async {
                
                print("추가 정보 갱신")
                
                let extra = ExtraPlaceInfo(infoList: data)
                
                self?.extraInfo = extra
                
                self?.placeInfoList.append(extra)
                
                self?.detailView.tableView.reloadData()

            }
            
        }
        
    }
    
    private func fetchDetailImages() {
        
        APIManager.shared.requestDetailImages(contentId: commonInfo.contentId) { [weak self] images in
            
            DispatchQueue.main.async {
                
                print("이미지 데이터 fetch")
                
                self?.images = images
                
                self?.detailView.imageHeaderView.pageControl.numberOfPages = images.count
                
                self?.detailView.imageHeaderView.collectionView.reloadSections([0])

            }
            
        }
        
    }
    
    override func configureNavigationItem() {
        
        let appear = UINavigationBarAppearance()
        appear.configureWithTransparentBackground()
        appear.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        
        navigationItem.standardAppearance = appear
        navigationItem.scrollEdgeAppearance = appear
        
        navigationController?.navigationBar.prefersLargeTitles = true
        title = commonInfo.title
        
    }
    
    // MARK: - Initailizer
    
    init(place: CommonPlaceInfo) {
        commonInfo = place
        super.init()
    }
    
}

// MARK: - TableView Datasource, Deleagte
extension DetailViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        placeInfoList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        placeInfoList[section].validateCell.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellType = placeInfoList[indexPath.section].validateCell[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellType.reuseIdentifier, for: indexPath)
        
        let section = Section.allCases[indexPath.section]
        
        switch section {
            
        case .common:
            switch cell {
            case let overview as OverviewInfoCell:
                overview.contentLabel.text = commonInfo.overview
                
            case let address as AddressInfoCell:
                address.contentLabel.text = commonInfo.fullAddress
                
            case let map as LocationInfoCell:
                map.marking(pos: commonInfo.position)
                
            case let web as WebPageInfoCell:
                web.contentLabel.text = commonInfo.homepage

            default:
                break
            }
            
        case .detail:
            guard let detail = detailInfo else { break }
            switch cell {
            case let time as TimeInfoCell:
                time.inputData(data: detail.timeData)
                time.checkValidation()

            case let event as EventInfoCell:
                event.inputData(data: detail.eventData)
                event.checkValidation()

            case let other as OtherDetailInfoCell:
                other.inputData(data: detail.otherData)
                other.checkValidation()

            default:
                break
            }
            
        case .extra:
            guard let extra = extraInfo else { break }
            
            let extraCell = cell as? ExtraInfoCell
            
            extraCell?.inputData(data: extra.infoList)
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        print(#function)
        
        if let cell = tableView.cellForRow(at: indexPath) as? OverviewInfoCell {
            cell.isExpand.toggle()
            tableView.reloadData()
        }
        
        
        //        tableView.reloadRows(at: [indexPath], with: .automatic)
        //        tableView.reloadData()
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        Section.allCases[section].title
    }
    
    
}
// MARK: - HeaderCollectionView Datasource, Deleagte

extension DetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        images.count > 0 ? images.count : 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DetailImageCell.reuseIdentifier, for: indexPath) as? DetailImageCell else { return UICollectionViewCell() }
        
        let url = images.count > 0 ? images[indexPath.row].originalImage : commonInfo.image
        
        cell.imageView.kf.setImage(with: URL(string: url))
        
        return cell
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let page = Int(targetContentOffset.pointee.x / scrollView.frame.width)
        
        detailView.imageHeaderView.pageControl.currentPage = page
        
      }
    
    
    
}
