//
//  PlaceDetailTapMeneViewModel.swift
//  KoreaTourist
//
//  Created by 김윤수 on 10/21/23.
//

import Foundation

import Combine

final class PlaceDetailTabMenuViewModel {
    private let useCase: CommonPlaceDetailUseCase
    private var tabMenus: [TabMenu] = []
    
    init(useCase: CommonPlaceDetailUseCase) {
        self.useCase = useCase
    }
    
    struct Input {
        let viewDidLoadEvent: AnyPublisher<Void, Never>
        let tabMenuTapEvent: AnyPublisher<Int, Never>
    }
    
    struct Output {
        let selectedMenu = PassthroughSubject<TabMenu, Never>()
        let visibleTabMenus = CurrentValueSubject<[TabMenu], Never>([])
    }
    
    func transform(input: Input, cancellables: inout Set<AnyCancellable>) -> Output {
        let output = Output()
        
        input.viewDidLoadEvent
            .withUnretained(self)
            .sink { object, _ in
                object.useCase.tryFetchPlaceDetailInformation()
            }
            .store(in: &cancellables)
        
        input.tabMenuTapEvent
            .withUnretained(self)
            .sink {
                output.selectedMenu.send($0.tabMenus[$1])
            }
            .store(in: &cancellables)
        
        self.useCase.detailInformations
            .withUnretained(self)
            .sink { object, info in
                if let intro = info.0 {
                    object.tabMenus.append(.intro(intro))
                }
                if let detail = info.1 {
                    object.tabMenus.append(.detail(detail))
                }
                if let extra = info.2 {
                    object.tabMenus.append(.extra(extra.list))
                }
                output.visibleTabMenus.send(object.tabMenus)
                output.selectedMenu.send(object.tabMenus[0])
            }
            .store(in: &cancellables)
        
        return output
    }
}

extension PlaceDetailTabMenuViewModel {
    // MARK: TabMenu
    enum TabMenu {
        case intro(Intro)
        case detail(DetailInformation)
        case extra([ExtraPlaceElement])
        
        var sections: [Section] {
            switch self {
            case let .intro(intro):
                var array: [Section] = []
                array += intro.overview.isEmpty ? [] : [.overview(intro)]
                array += intro.homepage.isEmpty ? [] : [.webpage(intro)]
                return array
            case let .detail(detail):
                let array = detail.detailInfoList.filter { $0.isValidate }
                return array.map { Section.detailInfo($0) }
            case let .extra(extra):
                let array = extra.filter { $0.isValidate }
                return [.extra(array)]
            }
        }
        
        var title: String {
            switch self {
            case .intro:
                return "소개"
            case .detail:
                return "정보"
            case .extra:
                return "안내"
            }
        }
    }

    enum Section {
        case overview(Intro)
        case webpage(Intro)
        case detailInfo(DetailInfo)
        case extra([ExtraPlaceElement])
    }
}

extension PlaceDetailTabMenuViewModel.Section: Hashable {
    static func == (lhs: PlaceDetailTabMenuViewModel.Section, rhs: PlaceDetailTabMenuViewModel.Section) -> Bool {
        switch (lhs, rhs) {
        case let (.overview(l), .overview(r)):
            return l == r
        case let (.webpage(l), .webpage(r)):
            return l == r
        case let (.detailInfo(l), .detailInfo(r)):
            return l.title == r.title
        case let (.extra(l), .extra(r)):
            return l == r
        default:
            return false
        }
    }
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case let .overview(intro):
            hasher.combine(intro.overview)
        case let .webpage(intro):
            hasher.combine(intro.homepage)
        case let .detailInfo(detailInfo):
            hasher.combine(detailInfo.title)
        case let .extra(array):
            hasher.combine(array)
        }
    }
}
