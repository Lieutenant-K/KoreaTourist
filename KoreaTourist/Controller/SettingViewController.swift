//
//  SettingViewController.swift
//  KoreaTourist
//
//  Created by 김윤수 on 2022/10/01.
//

import UIKit
import Then
import AcknowList
import MessageUI
import WebKit
import SafariServices

final class SettingViewController: BaseViewController {
    
    private let reuseIdentifier = "cell"
    
    private let cellTitles = ["오픈소스 라이브러리", "문의하기", "개인정보 처리방침", "앱 버전"]

    private lazy var tableView = UITableView().then {
        $0.delegate = self
        $0.dataSource = self
        $0.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
    }
    
    override func configureNavigationItem() {
        
        title = "설정"
        
        navigationItem.largeTitleDisplayMode = .never
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
    }

}

extension SettingViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellTitles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        
        var config = UIListContentConfiguration.sidebarCell()
        
        config.text = cellTitles[indexPath.row]
        config.textProperties.color = .label
        config.textProperties.font = .systemFont(ofSize: 18, weight: .regular)
        
        
        config.secondaryText = indexPath.row == 3 ? "1.0.0" : ""
        
        cell.contentConfiguration = config
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
            
        case 0:
            let vc = AcknowListViewController()
            vc.headerText = "목록"
            vc.title = "오픈소스 라이브러리"
            navigationController?.pushViewController(vc, animated: true)
        case 1:
            sendMail()
        case 2:
            let url = URL(string: "https://lietenant-k.tistory.com/100")!
            let vc = SFSafariViewController(url: url)
            present(vc, animated: true)
        default:
            break
            
        }
        
    }
    
    
    
}

extension SettingViewController: MFMailComposeViewControllerDelegate {
    
    func sendMail() {
            if MFMailComposeViewController.canSendMail(){
                let mail = MFMailComposeViewController()
                mail.setToRecipients(["setreetplace@gmail.com"])
                mail.setSubject("시플 - 문의하기")
                mail.setMessageBody("여러분의 소중한 의견을 들려주세요!", isHTML: false)
                
                mail.mailComposeDelegate = self
                self.present(mail, animated: true)
            } else {
                showAlert(title: "먼저 메일을 등록해주세요!")
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
//        showAlert(title: text)
//        print(result, error)
        self.dismiss(animated: true) { [weak self] in
            self?.showAlert(title: title, message: message)
        }
    }
    
}
