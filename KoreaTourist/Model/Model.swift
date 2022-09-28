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

class TourPlaceInfo: Information, PlaceInfo {
    
    struct TimeData: NeedValidate {
        
        let openDate: String
        let restDate: String
        let availableTime: String
        let availableSeason: String
        
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
    
    struct EventData: NeedValidate {
        let event: String
        let eventAge: String
        
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
    
    struct OtherData: NeedValidate {
        let contact: String
        let capacity: String
        let parking: String
        let stroller: String
        let creditCard: String
        let pet: String
        
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
    
    var eventData: EventData {
        EventData(event: event, eventAge: ageForEvent)
    }
    
    var otherData: OtherData {
        OtherData(contact: contactNumber, capacity: capacity, parking: parkingLot, stroller: strollerRentalInfo, creditCard: isAvailableCreditCard, pet: isAvailablePet)
    }
    
    var validateCell: [BaseInfoCell.Type] {
        let data: [NeedValidate] = [timeData, eventData, otherData]
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
        contactNumber = try container.decode(String.self, forKey: .contactNumber)
        openDate = try container.decode(String.self, forKey: .openDate)
        restDate = try container.decode(String.self, forKey: .restDate)
        event = try container.decode(String.self, forKey: .event)
        ageForEvent = try container.decode(String.self, forKey: .ageForEvent)
        capacity = try container.decode(String.self, forKey: .capacity)
        availableSeason = try container.decode(String.self, forKey: .availableSeason)
        availableTime = try container.decode(String.self, forKey: .availableTime)
        parkingLot = try container.decode(String.self, forKey: .parkingLot)
        strollerRentalInfo = try container.decode(String.self, forKey: .strollerRentalInfo)
        isAvailableCreditCard = try container.decode(String.self, forKey: .isAvailableCreditCard)
        isAvailablePet = try container.decode(String.self, forKey: .isAvailablePet)
    }
}


class CulturePlaceInfo: Information {
    
    @Persisted(primaryKey: true) var contentId: Int
    @Persisted var contentTypeId: String
    
    
}

class EventPlaceInfo: Information {
    @Persisted(primaryKey: true) var contentId: Int
    @Persisted var contentTypeId: String
}


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
    
    var detailInfoType: Information.Type {
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


struct Circle {
    
    static let defaultRadius: Double = 2000
    static let visitKorea = Circle(x: 126.981611, y: 37.568477, radius: defaultRadius)
    static let home = Circle(x: 126.924378, y: 37.503886, radius: defaultRadius)
    
    let x: Double
    let y: Double
    let radius: Double
    
}

let dummy = """
                [
                    {
                        "addr1": "서울시 동작구 대방동",
                        "addr2": "27길 27",
                        "areacode": "1",
                        "booktour": "0",
                        "cat1": "A02",
                        "cat2": "A0201",
                        "cat3": "A02010700",
                        "contentid": "126516",
                        "contenttypeid": "12",
                        "createdtime": "20031230090000",
                        "dist": "0",
                        "firstimage": "http://tong.visitkorea.or.kr/cms/resource/76/1568176_image2_1.jpg",
                        "firstimage2": "http://tong.visitkorea.or.kr/cms/resource/76/1568176_image3_1.jpg",
                        "mapx": "126.92461",
                        "mapy": "37.50400",
                        "mlevel": "6",
                        "modifiedtime": "20220518172825",
                        "readcount": 40150,
                        "sigungucode": "23",
                        "tel": "",
                        "title": "GS25 대방성남점"
                    },
                    {
                        "addr1": "서울시 동작구 대방동",
                        "addr2": "27길 25",
                        "areacode": "1",
                        "booktour": "0",
                        "cat1": "A02",
                        "cat2": "A0203",
                        "cat3": "A02030600",
                        "contentid": "735749",
                        "contenttypeid": "12",
                        "createdtime": "20090518192216",
                        "dist": "0",
                        "firstimage": "http://tong.visitkorea.or.kr/cms/resource/18/728318_image2_1.jpg",
                        "firstimage2": "http://tong.visitkorea.or.kr/cms/resource/18/728318_image3_1.jpg",
                        "mapx": "126.924100",
                        "mapy": "37.503831",
                        "mlevel": "6",
                        "modifiedtime": "20220322151730",
                        "readcount": 33860,
                        "sigungucode": "23",
                        "tel": "",
                        "title": "코코리퍼브"
                    },
                    {
                        "addr1": "서울시 동작구 대방동",
                        "addr2": "26길",
                        "areacode": "1",
                        "booktour": "0",
                        "cat1": "A02",
                        "cat2": "A0202",
                        "cat3": "A02020500",
                        "contentid": "2794933",
                        "contenttypeid": "12",
                        "createdtime": "20211214053541",
                        "dist": "0",
                        "firstimage": "http://tong.visitkorea.or.kr/cms/resource/43/2796243_image2_1.jpg",
                        "firstimage2": "http://tong.visitkorea.or.kr/cms/resource/43/2796243_image2_1.jpg",
                        "mapx": "126.924378",
                        "mapy": "37.502914",
                        "mlevel": "6",
                        "modifiedtime": "20220701145045",
                        "readcount": 0,
                        "sigungucode": "24",
                        "tel": "",
                        "title": "구립 대방 보듬이 나눔이 어린이집"
                    }
]

"""
