//
//  DetailViewController.swift
//  KakaoMap
//
//  Created by 김윤수 on 2022/09/16.
//

import UIKit
import Kingfisher
import Then

enum Section {
        
    case common
    case detail(ContentType)
    case extra
    
    var typeOfCell: [BaseInfoCell.Type] {
        switch self {
        case .common:
            
            return [OverviewInfoCell.self, AddressInfoCell.self, LocationInfoCell.self, WebPageInfoCell.self]
        case .detail(let type):
            switch type {
            case .tour:
                return [TimeInfoCell.self, EventInfoCell.self, OtherDetailInfoCell.self]
            case .culture:
                return []
            case .event:
                return []
            }
        case .extra:
            return [ExtraInfoCell.self]
        }
    }
    
    static func allCases(type: ContentType) -> [Self] {
        return [Section.common, Section.detail(type), Section.extra]
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
    }() {
        didSet {
            detailView.tableView.reloadData()
        }
    }
    
    let commonInfo: CommonPlaceInfo
    
    var images: [PlaceImage] = [] {
        didSet {
            detailView.imageHeaderView.pageControl.numberOfPages = images.count
            
            detailView.imageHeaderView.collectionView.reloadSections([0])
        }
    }
    
    lazy var detailView = DetailView().then { view in
        
        view.tableView.delegate = self
        view.tableView.dataSource = self
        view.imageHeaderView.collectionView.dataSource = self
        view.imageHeaderView.collectionView.delegate = self
        
        Section.allCases(type: commonInfo.contentType).forEach { section in
            section.typeOfCell.forEach { type in
                view.tableView.register(type, forCellReuseIdentifier: type.reuseIdentifier)
            }
        }
        
        
    }
    
    // MARK: - LifeCycle
    
    override func loadView() {
        view = detailView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkPlaceIntro()
        checkDetailInfoType()
        checkPlaceImages()
    }
    
    
    
    // MARK: - Method
    
    
    // MARK: Introduce Information
    
    private func checkPlaceIntro() {
        
        realm.fetchPlaceIntro(place: commonInfo) { [weak self] in
//            print("디테일 뷰컨에서 소개 정보 가져오기 완료")
            self?.detailView.tableView.reloadData()
        }
        
    }
    
    
    // MARK: Detail Place Information
    
    private func fetchDetailInfo<T:Information>(infoType: T.Type) {
        
        let id = commonInfo.contentId
        let type = commonInfo.contentType
        
        realm.fetchPlaceDetail(type: infoType, contentId: id, contentType: type) { [weak self] place in
            
            if let place = place as? PlaceInfo {
                self?.placeInfoList.append(place)
                self?.checkExtraInfoType()
            }
            
        }
        
    }
    
    private func checkDetailInfoType() {
        
        switch commonInfo.contentType {
        case .tour:
            fetchDetailInfo(infoType: TourPlaceInfo.self)
        case .event:
            fetchDetailInfo(infoType: EventPlaceInfo.self)
        case .culture:
            fetchDetailInfo(infoType: CulturePlaceInfo.self)
        }
        
    }
    
    
    // MARK: Extra Place Information
    
    private func checkExtraInfoType() {
        
        let id = commonInfo.contentId
        let type = commonInfo.contentType
        
        switch commonInfo.contentType {
        default:
            realm.fetchPlaceExtra(contentId: id, contentType: type) { [weak self] in
                
                self?.placeInfoList.append($0)
                
            }
        }
        
    }
    
    
    // MARK: Place Image Information
    
    private func checkPlaceImages() {
        
        realm.fetchPlaceImages(contentId: commonInfo.contentId) { [weak self] in
            self?.images = $0
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
//        print(section, placeInfoList[section].validateCell.count)
        return placeInfoList[section].validateCell.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellType = placeInfoList[indexPath.section].validateCell[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellType.reuseIdentifier, for: indexPath)
        
        let section = Section.allCases(type: commonInfo.contentType)[indexPath.section]
        
        switch section {
            
        case .common:
            switch cell {
            case let overview as OverviewInfoCell:
                overview.contentLabel.text = commonInfo.intro?.overview
                
            case let address as AddressInfoCell:
                address.contentLabel.text = commonInfo.fullAddress
                
            case let map as LocationInfoCell:
                map.marking(pos: commonInfo.position, date: commonInfo.discoverDate)
                
            case let web as WebPageInfoCell:
                web.contentLabel.text = commonInfo.intro?.homepage
                
            default:
                break
            }
            
        case .detail(let type):
            
            switch type {
            case .tour:
                guard let detail = realm.loadPlaceInfo(infoType: TourPlaceInfo.self, contentId: commonInfo.contentId) else { break }
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
            case .culture:
                break
            case .event:
                break
            }
             
            
        case .extra:
            
            guard let extra = realm.loadPlaceInfo(infoType: ExtraPlaceInfo.self, contentId: commonInfo.contentId) else { break }
            
            let extraCell = cell as? ExtraInfoCell
            
            extraCell?.inputData(data: extra.list)
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
        Section.allCases(type: commonInfo.contentType)[section].title
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
