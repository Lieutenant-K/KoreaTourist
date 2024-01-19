//
//  SettingViewModel.swift
//  KoreaTourist
//
//  Created by 김윤수 on 1/18/24.
//

import Foundation
import Combine
import MessageUI

final class SettingViewModel: NSObject {
    typealias AlertTitleMessage = (title: String, message: String)
    
    weak var coordinator: SettingCoordinator?
    private let alertTitleAndMessage = PassthroughSubject<AlertTitleMessage, Never>()
    
    deinit {
        self.coordinator?.finish()
    }
    
    struct Input {
        let viewDidLoadEvent: AnyPublisher<Void, Never>
        let didSelectItemAtEvent: AnyPublisher<Item, Never>
    }
    
    struct Output {
        let items = CurrentValueSubject<[Item], Never>([])
        let alertTitleAndMessage: AnyPublisher<AlertTitleMessage, Never>
    }
    
    func transform(input: Input, cancellables: inout Set<AnyCancellable>) -> Output {
        let output = Output(alertTitleAndMessage: self.alertTitleAndMessage.eraseToAnyPublisher())
        
        input.viewDidLoadEvent
            .map { Item.allCases }
            .sink {
                output.items.send($0)
            }
            .store(in: &cancellables)
        
        input.didSelectItemAtEvent
            .withUnretained(self)
            .sink {
                switch $1 {
                case .openSource:
                    $0.coordinator?.pushOpenSourceListScene()
                case .email:
                    $0.sendMail()
                case .privacy:
                    $0.coordinator?.presentPrivacyWebPageScene()
                case .version:
                    break
                }
            }
            .store(in: &cancellables)
        
        return output
    }
}

extension SettingViewModel {
    enum Item: CaseIterable {
        case openSource
        case email
        case privacy
        case version
        
        var title: String {
            switch self {
            case .openSource:
                "오픈소스 라이브러리"
            case .email:
                "문의하기"
            case .privacy:
                "개인정보 처리방침"
            case .version:
                "앱 버전"
            }
        }
    }
}

extension SettingViewModel: MFMailComposeViewControllerDelegate {
    private func sendMail() {
            if MFMailComposeViewController.canSendMail(){
                let mail = MFMailComposeViewController()
                mail.setToRecipients(["setreetplace@gmail.com"])
                mail.setSubject("시플 - 문의하기")
                mail.setMessageBody("여러분의 소중한 의견을 들려주세요!", isHTML: false)
                mail.mailComposeDelegate = self
                self.coordinator?.navigationController.present(mail, animated: true)
            } else {
                let title = "먼저 메일을 등록해주세요!"
                self.alertTitleAndMessage.send((title, ""))
            }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        var title = ""
        var message = ""
        
        switch result {
        case .cancelled:
            title = "메일 전송이 취소됐습니다."
        case .saved:
            title = "메일이 임시 저장됐습니다."
            message = "의견을 보내시려면 메일을 전송해주세요"
        case .sent:
            title = "메일이 성공적으로 전송됐습니다."
            message = "소중한 의견에 감사드립니다."
        case .failed:
            title = "메일 전송이 실패했습니다."
            message = "다시 시도해주세요"
        default:
            title = "예상하지 못한 에러가 발생했습니다."
        }
        self.coordinator?.navigationController.dismiss(animated: true) { [weak self] in
            self?.alertTitleAndMessage.send((title, message))
        }
    }
}
