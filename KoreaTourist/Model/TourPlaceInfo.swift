//
//  TourPlaceInfo.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2022/12/18.
//

import UIKit
import RealmSwift

class TourPlaceInfo: Object {
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

extension TourPlaceInfo: DetailInformation {
    var detailInfoList: [DetailInfo] {
        [timeData, experienceData, serviceData]
    }
    
    var contentType: ContentType {
        get { ContentType(rawValue: contentTypeId)! }
        set { contentTypeId = newValue.rawValue }
    }
}

// MARK: - TimeData
extension TourPlaceInfo {
    struct TimeData: DetailInfo {
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
    }
    
    var timeData: TimeData {
        TimeData(openDate: openDate, restDate: restDate, availableTime: availableTime, availableSeason: availableSeason)
    }
}

// MARK: - ExperienceData
extension TourPlaceInfo {
    struct ExperienceData: DetailInfo {
        let event: String
        let eventAge: String
        var title: String { "체험 안내" }
        
        var iconImage: UIImage? {
            UIImage(systemName: "exclamationmark.circle.fill")
        }
        
        var contentList: [(String, String)] {
            [ ("체험", event)
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
    }
    
    var experienceData: ExperienceData {
        ExperienceData(event: event, eventAge: ageForEvent)
    }
}

// MARK: - ServiceData
extension TourPlaceInfo {
    struct ServiceData: DetailInfo {
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
    }

    var serviceData: ServiceData {
        ServiceData(contact: contactNumber, capacity: capacity, parking: parkingLot, stroller: strollerRentalInfo, creditCard: isAvailableCreditCard, pet: isAvailablePet)
    }
}
