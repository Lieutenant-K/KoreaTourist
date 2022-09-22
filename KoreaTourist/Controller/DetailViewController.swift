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
    
//    var detailInfo: TourPlaceInfo?
//    var extraInfo: ExtraPlaceInfo?
    
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

        checkDetailInfo()
        checkPlaceImages()
    }
    
    
    
    // MARK: - Method
    
    
    
    // MARK: Detail Place Information
    
    private func fetchDetailPlaceInfo<T: Information>(type: T.Type) {
        
        APIManager.shared.requestDetailPlaceInfo(contentId: commonInfo.contentId, contentType: commonInfo.contentType) { [weak self] (data: T) in
            
            print("디테일 데이터 응답 받았다!")
//            print(data)
            
            self?.receivedDetailInfo(info: data)
            
            
        }
        
    }
    
    private func receivedDetailInfo(info: Information) {
        
        realm.registPlaceInfo(info: info)
        
        if let info = info as? PlaceInfo {
            placeInfoList.append(info)
            
//                self?.fetchExtraPlaceInfo()
            checkExtraInfo()
        }
        
    }
    
    private func checkDetailInfo() {
        
        let type = commonInfo.contentType.detailInfoType
        
        if let detail = realm.loadPlaceInfo(infoType: type.self, contentId: commonInfo.contentId) as? PlaceInfo {
            placeInfoList.append(detail)
            checkExtraInfo()
        } else {
            switch type {
            case let tour as TourPlaceInfo.Type:
                fetchDetailPlaceInfo(type: tour.self)
            case let culture as CulturePlaceInfo.Type:
                fetchDetailPlaceInfo(type: culture.self)
            case let event as EventPlaceInfo.Type:
                fetchDetailPlaceInfo(type: event.self)
            default:
                break
            }
        }
        
    }
    
    
    // MARK: Extra Place Information
    
    private func checkExtraInfo() {
        
        if let extra = realm.loadPlaceInfo(infoType: ExtraPlaceInfo.self, contentId: commonInfo.contentId) {
            placeInfoList.append(extra)
        } else {
            fetchExtraPlaceInfo()
        }
        
    }
    
    private func receivedExtraInfo(info: [ExtraPlaceElement]) {
        
        let extra = ExtraPlaceInfo(id: commonInfo.contentId, infoList: info)
        
        realm.registPlaceInfo(info: extra)
        
        placeInfoList.append(extra)
        
    }
    
    private func fetchExtraPlaceInfo() {
        
        APIManager.shared.requestExtraPlaceInfo(contentId: commonInfo.contentId, contentType: commonInfo.contentType) { [weak self] (data: [ExtraPlaceElement]) in
            
            print("추가 정보 갱신")
            
            self?.receivedExtraInfo(info: data)
            
        }
        
    }
    
    // MARK: Place Image Information
    
    private func checkPlaceImages() {
        
        if let images = realm.loadPlaceInfo(infoType: PlaceImageInfo.self, contentId: commonInfo.contentId) {
            self.images = images.images
        } else {
            fetchPlaceImages()
        }
        
    }
    
    private func fetchPlaceImages() {
        
        APIManager.shared.requestDetailImages(contentId: commonInfo.contentId) { [weak self] images in
            
            print("이미지 데이터 fetch")
            
            self?.receivedPlaceImageInfo(info: images)
        }
        
    }
    
    func receivedPlaceImageInfo(info: [PlaceImage]) {
        
        let placeImage = PlaceImageInfo(id: commonInfo.contentId, imageList: info)
        
        realm.registPlaceInfo(info: placeImage)
        
        self.images = info
        
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
                map.marking(pos: commonInfo.position)
                
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
             
            
            /*
            guard let detail = detailInfo else { break }
//            guard let info = realm.loadPlaceInfo(infoType: commonInfo.contentType.detailInfoType, contentId: commonInfo.contentId) else { break }
            
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
            */
            
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
