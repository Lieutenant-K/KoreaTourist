//
//  Model.swift
//  KakaoMap
//
//  Created by 김윤수 on 2022/09/11.
//

import Foundation
import NMapsMap
import RealmSwift

typealias Information = Object & Codable

protocol PlaceInfo {
    
    var validateCell: [BaseInfoCell.Type] { get }
    
}

protocol NeedValidate {
    
    var isValidate: Bool { get }
    
    var releativeCell: BaseInfoCell.Type { get }
}

protocol SubInfoElementController: UIViewController {
    
    var elementView: UITableView { get }
    
//    var dataSource: UITableViewDataSource { get set }
    
    func updateSnapshot()
}

protocol IntroCell: UITableViewCell {
    
    func inputData(intro: Intro)
}

protocol ExpandableCell: UITableViewCell {
    
    var arrowImage: UIImageView { get }
    
    var isExpand: Bool { get set }
}

protocol DetailInfo {
    
    var iconImage: UIImage? { get }
    var title: String { get }
    var contentList: [(String, String)] { get }
    var isValidate: Bool { get }
    
}

protocol DetailInformation: Information {
    
    var detailInfoList: [DetailInfo] { get }
    
    var contentType: ContentType { get }
    
    var contentId: Int { get }
    
}

// MARK: - DetailCommon
struct Result<T:Codable>: Codable {
    let response: Response<T>
}

// MARK: - Response
struct Response<T:Codable>: Codable {
    let header: Header
    let body: Body<T>
}

// MARK: - Header
struct Header: Codable {
    let resultCode, resultMsg: String
}


// MARK: - Body
struct Body<T:Codable>: Codable {
    let items: Items<T>
    let numOfRows, pageNo, totalCount: Int
}

// MARK: - Items
struct Items<T:Codable>: Codable {
    let item: [T]
}

// MARK: - Item



// MARK: Common Place Info

class CommonPlaceInfo: Information, PlaceInfo {
    
    @Persisted var addr1: String
    @Persisted var addr2: String
    @Persisted var cat1: String
    @Persisted var cat2: String
    @Persisted var cat3: String
    @Persisted var dist: Double
    @Persisted var title: String
    @Persisted var areaCode: Int
    @Persisted var subAreaCode: Int
    @Persisted(primaryKey: true) var contentId: Int
    @Persisted var contentTypeId: String
    @Persisted var image: String
    @Persisted var thumbnail: String
    @Persisted var lat: Double
    @Persisted var lng: Double
    @Persisted var discoverDate: Date?
    @Persisted var intro: Intro?
    
    var contentType: ContentType {
        get { ContentType(rawValue: contentTypeId)! }
        set { contentTypeId = newValue.rawValue }
    }
    
    var isDiscovered: Bool {
        return discoverDate == nil ? false : true
    }
    
    var fullAddress: String {
        var address = [addr1, addr2]
        if let zip = intro?.zipcode {
            address.append("(\(zip))")
        }
        return address.joined(separator: " ")
    }
    
    var isImageIncluded: Bool {
        return !image.isEmpty || !thumbnail.isEmpty
    }
    
    var position: NMGLatLng {
        NMGLatLng(lat: lat, lng: lng)
    }
    
    var validateCell: [BaseInfoCell.Type] {
        var list = [OverviewInfoCell.self, AddressInfoCell.self, LocationInfoCell.self]
        if let intro = intro, !intro.homepage.isEmpty {
            list.append(WebPageInfoCell.self)
        }
        return list
    }
    
    enum CodingKeys: String, CodingKey {
        case addr1, addr2, cat1, cat2, cat3, dist, title//, zipcode, overview, homepage, tel
        case areaCode = "areacode"
        case subAreaCode = "sigungucode"
        case contentId = "contentid"
        case contentTypeId = "contenttypeid"
        case image = "firstimage"
        case thumbnail = "firstimage2"
        case lat = "mapy"
        case lng = "mapx"
        //case telName = "telname"
        
    }
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        addr1 = try container.decode(String.self, forKey: .addr1)
        addr2 = try container.decode(String.self, forKey: .addr2)
        cat1 = try container.decode(String.self, forKey: .cat1)
        cat2 = try container.decode(String.self, forKey: .cat2)
        cat3 = try container.decode(String.self, forKey: .cat3)
//        dist = Double(try container.decodeIfPresent(String.self, forKey: .dist) ?? "") ?? 0
        dist = Double(try container.decode(String.self, forKey: .dist)) ?? 0
        title = try container.decode(String.self, forKey: .title)
        areaCode = Int(try container.decode(String.self, forKey: .areaCode)) ?? 0
        subAreaCode = Int(try container.decode(String.self, forKey: .subAreaCode)) ?? 0
        contentId = Int(try container.decode(String.self, forKey: .contentId)) ?? 0
        contentTypeId = try container.decode(String.self, forKey: .contentTypeId)
        image = try container.decode(String.self, forKey: .image)
        thumbnail = try container.decode(String.self, forKey: .thumbnail)
        lat = Double(try container.decode(String.self, forKey: .lat)) ?? 0
        lng = Double(try container.decode(String.self, forKey: .lng)) ?? 0
//        zipcode = Int(try container.decodeIfPresent(String.self, forKey: .zipcode) ?? "") ?? 0
//
//        overview = (try container.decodeIfPresent(String.self, forKey: .overview) ?? "").htmlEscaped.refine
//
//        homepage = (try container.decodeIfPresent(String.self, forKey: .homepage) ?? "").htmlEscaped
//
//        tel = try container.decodeIfPresent(String.self, forKey: .tel) ?? ""
//        telName = try container.decodeIfPresent(String.self, forKey: .telName) ?? ""
        
    }
    
}

// MARK: Intro

class Intro: EmbeddedObject, Codable {
    
    @Persisted var zipcode: Int
    @Persisted var overview: String
    @Persisted var homepage : String
    @Persisted var tel: String
    @Persisted var telName: String
    
    enum CodingKeys: String, CodingKey {
        case zipcode, overview, homepage, tel
        case telName = "telname"
    }
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        zipcode = Int(try container.decode(String.self, forKey: .zipcode)) ?? 0
        overview = (try container.decode(String.self, forKey: .overview)).htmlEscaped.refine
        homepage = (try container.decode(String.self, forKey: .homepage)).htmlEscaped
        tel = try container.decode(String.self, forKey: .tel)
        telName = try container.decode(String.self, forKey: .telName)
    }
    
}

// MARK: Tour Place Info

class TourPlaceInfo: Information, PlaceInfo, DetailInformation {
    
    var detailInfoList: [DetailInfo] {
        [timeData, experienceData, serviceData]
    }
    
    var contentType: ContentType {
        get { ContentType(rawValue: contentTypeId)! }
        set { contentTypeId = newValue.rawValue }
    }
    
    struct TimeData: NeedValidate, DetailInfo {
        
        let openDate: String
        let restDate: String
        let availableTime: String
        let availableSeason: String
        
        var title: String { "시간 안내" }
        
        var iconImage: UIImage? {
            UIImage(systemName: "stopwatch.fill")
        }
        
        var contentList: [(String, String)] {
            [ ("개장일", openDate)
              ,("휴일", restDate)
              ,("이용 가능 시간", availableTime)
              ,("이용 가능 시기", availableSeason)
            ]
        }
        
        var isValidate: Bool {
            var validate = false
            [openDate, restDate, availableSeason, availableTime].forEach {
                validate = validate || !$0.isEmpty ? true : false
            }
            return validate
        }
        
        var releativeCell: BaseInfoCell.Type {
            TimeInfoCell.self
        }
        
    }
    
    struct ExperienceData: NeedValidate, DetailInfo {
        
        let event: String
        let eventAge: String
        
        var title: String { "체험 안내" }
        
        var iconImage: UIImage? {
            UIImage(systemName: "exclamationmark.circle.fill")
        }
        
        var contentList: [(String, String)] {
            [ ("행사", event)
              ,("가능 연령", eventAge)
            ]
        }
        
        var isValidate: Bool {
            var validate = false
            [event, eventAge].forEach {
                validate = validate || !$0.isEmpty ? true : false
            }
            return validate
        }
        
        var releativeCell: BaseInfoCell.Type {
            EventInfoCell.self
        }
    }
    
    struct ServiceData: NeedValidate, DetailInfo {
        let contact: String
        let capacity: String
        let parking: String
        let stroller: String
        let creditCard: String
        let pet: String
        
        var title: String { "서비스" }
        
        var iconImage: UIImage? {
            UIImage(systemName: "person.fill")
        }
        
        var contentList: [(String, String)] {
            [ ("문의 및 안내", contact)
              ,("수용인원", capacity)
              ,("주차장 여부", parking)
              ,("유모차 대여 여부", stroller)
              ,("신용카드 가능 여부", creditCard)
              ,("애완동물 가능 여부", pet)
            ]
        }
        
        var isValidate: Bool {
            var validate = false
            [contact, capacity, parking, stroller, creditCard, pet].forEach {
                validate = validate || !$0.isEmpty ? true : false
            }
            return validate
        }
        
        var releativeCell: BaseInfoCell.Type {
            OtherDetailInfoCell.self
        }
    }
    
    @Persisted(primaryKey: true) var contentId: Int
    @Persisted var contentTypeId: String
    @Persisted var cultureHeritage: Bool
    @Persisted var natureHeritage:Bool
    @Persisted var recordHeritage: Bool
    @Persisted var contactNumber: String
    @Persisted var openDate: String
    @Persisted var restDate: String
    @Persisted var event: String
    @Persisted var ageForEvent: String
    @Persisted var capacity: String
    @Persisted var availableSeason: String
    @Persisted var availableTime: String
    @Persisted var parkingLot: String
    @Persisted var strollerRentalInfo: String
    @Persisted var isAvailablePet: String
    @Persisted var isAvailableCreditCard: String
    
    var timeData: TimeData {
        TimeData(openDate: openDate, restDate: restDate, availableTime: availableTime, availableSeason: availableSeason)
    }
    
    var experienceData: ExperienceData {
        ExperienceData(event: event, eventAge: ageForEvent)
    }
    
    var serviceData: ServiceData {
        ServiceData(contact: contactNumber, capacity: capacity, parking: parkingLot, stroller: strollerRentalInfo, creditCard: isAvailableCreditCard, pet: isAvailablePet)
    }
    
    var validateCell: [BaseInfoCell.Type] {
        let data: [NeedValidate] = [timeData, experienceData, serviceData]
        return data.filter { $0.isValidate == true }.map { $0.releativeCell }
    }
    
    enum CodingKeys: String, CodingKey {
        case contentId = "contentid"
        case contentTypeId = "contenttypeid"
        case cultureHeritage = "heritage1"
        case natureHeritage = "heritage2"
        case recordHeritage = "heritage3"
        case contactNumber = "infocenter"
        case openDate = "opendate"
        case restDate = "restdate"
        case event = "expguide"
        case ageForEvent = "expagerange"
        case capacity = "accomcount"
        case availableSeason = "useseason"
        case availableTime = "usetime"
        case parkingLot = "parking"
        case strollerRentalInfo = "chkbabycarriage"
        case isAvailableCreditCard = "chkcreditcard"
        case isAvailablePet = "chkpet"
        
    }
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        contentId = Int(try container.decode(String.self, forKey: .contentId)) ?? 0
        contentTypeId = try container.decode(String.self, forKey: .contentTypeId)
        cultureHeritage = try container.decode(String.self, forKey: .cultureHeritage) == "1"
        natureHeritage = try container.decode(String.self, forKey: .natureHeritage) == "1"
        recordHeritage = try container.decode(String.self, forKey: .recordHeritage) == "1"
        contactNumber = try container.decode(String.self, forKey: .contactNumber).htmlEscaped
        openDate = try container.decode(String.self, forKey: .openDate).htmlEscaped
        restDate = try container.decode(String.self, forKey: .restDate).htmlEscaped
        event = try container.decode(String.self, forKey: .event).htmlEscaped
        ageForEvent = try container.decode(String.self, forKey: .ageForEvent).htmlEscaped
        capacity = try container.decode(String.self, forKey: .capacity)
        availableSeason = try container.decode(String.self, forKey: .availableSeason).htmlEscaped
        availableTime = try container.decode(String.self, forKey: .availableTime).htmlEscaped
        parkingLot = try container.decode(String.self, forKey: .parkingLot).htmlEscaped
        strollerRentalInfo = try container.decode(String.self, forKey: .strollerRentalInfo).htmlEscaped
        isAvailableCreditCard = try container.decode(String.self, forKey: .isAvailableCreditCard).htmlEscaped
        isAvailablePet = try container.decode(String.self, forKey: .isAvailablePet).htmlEscaped
    }
}


class CulturePlaceInfo: Information, DetailInformation {
    
    var detailInfoList: [DetailInfo] { [] }
    
    var contentType: ContentType {
        get { ContentType(rawValue: contentTypeId)! }
        set { contentTypeId = newValue.rawValue }
    }
    
    
    @Persisted(primaryKey: true) var contentId: Int
    @Persisted var contentTypeId: String
    
    
}

class EventPlaceInfo: Information, DetailInformation {
    
    var detailInfoList: [DetailInfo] { [] }
    
    var contentType: ContentType {
        get { ContentType(rawValue: contentTypeId)! }
        set { contentTypeId = newValue.rawValue }
    }
    
    @Persisted(primaryKey: true) var contentId: Int
    @Persisted var contentTypeId: String
}


// MARK: Extra Place Info

class ExtraPlaceInfo: Object, PlaceInfo {
    
    @Persisted(primaryKey: true) var contentId: Int
    @Persisted var infoList: List<ExtraPlaceElement>
    
    var validateCell: [BaseInfoCell.Type] {
        var validate = false
        infoList.forEach { validate = validate || $0.isValidate }
        return validate ? [ExtraInfoCell.self] : []
    }
    
    var list: [ExtraPlaceElement] {
        get { infoList.map { $0 } }
        set {
            infoList.removeAll()
            infoList.append(objectsIn: newValue)
        }
    }
    
    convenience init(id: Int, infoList: [ExtraPlaceElement]) {
        self.init()
        contentId = id
        list = infoList
//        let list = List<ExtraPlaceElement>()
//        infoList.forEach { list.append($0) }
//        self.infoList = list
    }
}

class ExtraPlaceElement: EmbeddedObject, Codable, NeedValidate {
    
    @Persisted var infoText: String
    @Persisted var infoTitle: String
    @Persisted var index: Int
    @Persisted var infoType: Int
    
    var isValidate: Bool {
        var validate = false
        [infoText, infoTitle].forEach {
            validate = validate || !$0.isEmpty ? true : false
        }
        return validate
    }
    
    var releativeCell: BaseInfoCell.Type {
        ExtraInfoCell.self
    }
    
    enum CodingKeys: String, CodingKey {
        case index = "serialnum"
        case infoTitle = "infoname"
        case infoText = "infotext"
        case infoType = "fldgubun"
    }
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        index = Int(try container.decode(String.self, forKey: .index)) ?? -1
        infoType = Int(try container.decode(String.self, forKey: .infoType)) ?? 0
        infoText = try container.decode(String.self, forKey: .infoText).htmlEscaped
        infoTitle = try container.decode(String.self, forKey: .infoTitle).htmlEscaped
    }
}


// MARK: Place Image Info

class PlaceImageInfo: Object {
    
    @Persisted(primaryKey: true) var contentId: Int
    @Persisted var imageList: List<PlaceImage>
    
    var images: [PlaceImage] {
        get { imageList.map { $0 } }
        set {
            imageList.removeAll()
            imageList.append(objectsIn: newValue)
        }
    }
    
    convenience init(id: Int, imageList: [PlaceImage]) {
        self.init()
        contentId = id
        images = imageList
    }
}

class PlaceImage: EmbeddedObject, Codable {
    
    @Persisted var originalImage: String
    @Persisted var imageName: String
    @Persisted var smallImage: String
    @Persisted var serialNumber: String
    
    enum CodingKeys: String, CodingKey {
        case originalImage = "originimgurl"
        case imageName = "imgname"
        case smallImage = "smallimageurl"
        case serialNumber = "serialnum"
    }
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        originalImage = try container.decode(String.self, forKey: .originalImage)
        smallImage = try container.decode(String.self, forKey: .smallImage)
        imageName = try container.decode(String.self, forKey: .imageName)
        serialNumber = try container.decode(String.self, forKey: .serialNumber)
    }
}


// MARK: Area Code

class AreaCode: Object, Codable {
    
    @Persisted(primaryKey: true) var id: Int
    @Persisted var name: String
    
    enum CodingKeys: String, CodingKey {
        
        case id = "code"
        case name
        
    }
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = Int(try container.decode(String.self, forKey: .id)) ?? -1
        name = try container.decode(String.self, forKey: .name)
    }
    
}

// MARK: Content Type

enum ContentType: String, Codable {
    
    case tour = "12"
    case culture = "14"
    case event = "15"
    
    var description: String {
        switch self {
        case .tour:
            return "관광지"
        case .culture:
            return "문화시설"
        case .event:
            return "행사/공연/축제"
        }
    }
    
    var detailInfoType: DetailInformation.Type {
        switch self {
        case .tour:
            return TourPlaceInfo.self
        case .culture:
            return CulturePlaceInfo.self
        case .event:
            return EventPlaceInfo.self
        }
    }
    
}

// MARK: Circle

struct Circle {
    
    static let defaultRadius: Double = 500
    static let visitKorea = Circle(x: 126.981611, y: 37.568477, radius: defaultRadius)
    static let home = Circle(x: 126.924378, y: 37.503886, radius: defaultRadius)
    
    let x: Double
    let y: Double
    let radius: Double
    
}

// MARK: - XMLDecoding

struct XMLHeader: Codable {
    
    let errMsg: String
    let returnAuthMsg: String
    let returnReasonCode: String
    
}

struct ServiceResponse: Codable {
    
    let cmmMsgHeader: XMLHeader
    
}

enum FailureReason {
    
    case apiError(ServiceResponse)
    case noData
    
}
