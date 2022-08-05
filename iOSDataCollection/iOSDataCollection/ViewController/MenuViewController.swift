//
//  MenuViewController.swift
//  iOSDataCollection
//
//  Created by ROLF J. on 2022/08/02.
//

import UIKit
import SafariServices

class MenuViewController: UIViewController {
    
    static let shared = MenuViewController()
    
    // MARK: - Instance member
    // 유저 ID를 보여주는 Label
    private let userIDLabel: UILabel = {
        let label = UILabel()
        label.text = UserDefaults.standard.string(forKey: "ID")
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 50)
        
        return label
    }()
    
    // '사용방법' 노션으로 이동하는 것을 알리는 Label
    private let testNotionLabel: UILabel = {
        let label = UILabel()
        label.text = "'사용방법' 노션 페이지로 이동합니다."
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 13)
        label.textAlignment = .center
        
        return label
    }()
    
    // '사용방법' 노션 페이지로 이동하는 버튼
    private let testNotionButton: UIButton = {
        let button = UIButton()
        button.clipsToBounds = true
        button.setTitle("사용방법 확인하기", for: .normal)
        var buttonConfiguration = UIButton.Configuration.filled()
        buttonConfiguration.baseBackgroundColor = .darkGray
        buttonConfiguration.baseForegroundColor = .white
        button.configuration = buttonConfiguration
        
        return button
    }()
    
    // '주의사항' 노션으로 이동하는 것을 알리는 Label
    private let warningNotionLabel: UILabel = {
        let label = UILabel()
        label.text = "'주의사항' 노션 페이지로 이동합니다."
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 13)
        label.textAlignment = .center
        
        return label
    }()
    
    // '주의사항' 노션 페이지로 이동하는 버튼
    private let warningNotionButton: UIButton = {
        let button = UIButton()
        button.clipsToBounds = true
        button.setTitle("주의사항 확인하기", for: .normal)
        var buttonConfiguration = UIButton.Configuration.filled()
        buttonConfiguration.baseBackgroundColor = .darkGray
        buttonConfiguration.baseForegroundColor = .white
        button.configuration = buttonConfiguration
        
        return button
    }()
    
    // '문의사항' 노션으로 이동하는 것을 알리는 Label
    private let contactNotionLabel: UILabel = {
        let label = UILabel()
        label.text = "'문의하기' 노션 페이지로 이동합니다."
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 13)
        label.textAlignment = .center
        
        return label
    }()
    
    // '문의사항' 노션 페이지로 이동하는 버튼
    private let contactNotionButton: UIButton = {
        let button = UIButton()
        button.clipsToBounds = true
        button.setTitle("문의 메일 확인하기", for: .normal)
        var buttonConfiguration = UIButton.Configuration.filled()
        buttonConfiguration.baseBackgroundColor = .darkGray
        buttonConfiguration.baseForegroundColor = .white
        button.configuration = buttonConfiguration
        
        return button
    }()
    
    // 설문조사 가입 페이지로 이동하는 것을 알리는 Label
    private let surveyRegisterLabel: UILabel = {
        let label = UILabel()
        label.text = "설문조사 회원가입 웹페이지로 이동합니다."
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 13)
        label.textAlignment = .center
        
        return label
    }()
    
    // 설문조사 회원가입 페이지로 이동하는 버튼
    private let surveyRegisterButton: UIButton = {
        let button = UIButton()
        button.clipsToBounds = true
        button.setTitle("설문조사 회원가입하기", for: .normal)
        var buttonConfiguration = UIButton.Configuration.filled()
        buttonConfiguration.baseBackgroundColor = .darkGray
        buttonConfiguration.baseForegroundColor = .white
        button.configuration = buttonConfiguration
        
        return button
    }()
    
    // 설문조사 페이지로 이동하는 것을 알리는 Label
    private let surveyLabel: UILabel = {
        let label = UILabel()
        label.text = "설문조사 웹페이지로 이동합니다."
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 13)
        label.textAlignment = .center
        
        return label
    }()
    
    // 설문조사 페이지로 이동하는 버튼
    private let surveyButton: UIButton = {
        let button = UIButton()
        button.clipsToBounds = true
        button.setTitle("설문조사 참여하기", for: .normal)
        var buttonConfiguration = UIButton.Configuration.filled()
        buttonConfiguration.baseBackgroundColor = .darkGray
        buttonConfiguration.baseForegroundColor = .white
        button.configuration = buttonConfiguration
        
        return button
    }()
    
    // 로그아웃 경고를 나타낼 Label
    private let warningLogOutLabel: UILabel = {
        let label = UILabel()
        label.text = "Warning : 로그아웃은 ID가 잘못되었을 때만 사용해주세요."
        label.textColor = .systemRed
        label.font = UIFont.systemFont(ofSize: 13)
        label.textAlignment = .center
        
        return label
    }()
    
    // 로그아웃 버튼
    private let logOutButton: UIButton = {
        let button = UIButton()
        button.clipsToBounds = true
        button.setTitle("로그아웃", for: .normal)
        var buttonConfiguration = UIButton.Configuration.filled()
        buttonConfiguration.baseBackgroundColor = .systemRed
        buttonConfiguration.baseForegroundColor = .white
        button.configuration = buttonConfiguration
        
        return button
    }()
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        menuViewLayout()
    }
    
    // MARK: - Method
    // Menu View의 레이아웃 설정
    private func menuViewLayout() {
        addSubViews()
        
        userIDLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(-40)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(20)
        }
        
        testNotionLabel.snp.makeConstraints { make in
            make.top.equalTo(userIDLabel.snp.bottom).offset(30)
            make.width.equalTo(view)
        }
        
        testNotionButton.snp.makeConstraints { make in
            make.top.equalTo(testNotionLabel.snp.bottom).offset(5)
            make.width.equalToSuperview()
            make.height.equalTo(45)
        }
        testNotionButton.addTarget(self, action: #selector(pressTestNotionButton), for: .touchUpInside)
        
        warningNotionLabel.snp.makeConstraints { make in
            make.top.equalTo(testNotionButton.snp.bottom).offset(15)
            make.width.equalTo(view)
        }
        
        warningNotionButton.snp.makeConstraints { make in
            make.top.equalTo(warningNotionLabel.snp.bottom).offset(5)
            make.width.equalToSuperview()
            make.height.equalTo(45)
        }
        warningNotionButton.addTarget(self, action: #selector(pressWarningNotionButton), for: .touchUpInside)
        
        contactNotionLabel.snp.makeConstraints { make in
            make.top.equalTo(warningNotionButton.snp.bottom).offset(15)
            make.width.equalTo(view)
        }
        
        contactNotionButton.snp.makeConstraints { make in
            make.top.equalTo(contactNotionLabel.snp.bottom).offset(5)
            make.width.equalToSuperview()
            make.height.equalTo(45)
        }
        contactNotionButton.addTarget(self, action: #selector(pressContactNotionButton), for: .touchUpInside)
        
        surveyRegisterLabel.snp.makeConstraints { make in
            make.top.equalTo(contactNotionButton.snp.bottom).offset(15)
            make.width.equalTo(view)
        }
        
        surveyRegisterButton.snp.makeConstraints { make in
            make.top.equalTo(surveyRegisterLabel.snp.bottom).offset(5)
            make.width.equalToSuperview()
            make.height.equalTo(45)
        }
        surveyRegisterButton.addTarget(self, action: #selector(pressSurveyRegisterButton), for: .touchUpInside)
        
        surveyLabel.snp.makeConstraints { make in
            make.top.equalTo(surveyRegisterButton.snp.bottom).offset(15)
            make.width.equalTo(view)
        }
        
        surveyButton.snp.makeConstraints { make in
            make.top.equalTo(surveyLabel.snp.bottom).offset(5)
            make.width.equalToSuperview()
            make.height.equalTo(45)
        }
        surveyButton.addTarget(self, action: #selector(pressSurveyButton), for: .touchUpInside)
        
        logOutButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
            make.centerX.equalToSuperview()
            make.width.equalTo(view.frame.width/4)
            make.height.equalTo(40)
        }
        logOutButton.addTarget(self, action: #selector(pressLogOutButton), for: .touchUpInside)
        
        warningLogOutLabel.snp.makeConstraints { make in
            make.bottom.equalTo(logOutButton.snp.top).offset(-10)
            make.width.equalTo(view)
        }
        
    }
    
    // AddSubView를 한 번에 실시
    private func addSubViews() {
        let views = [userIDLabel, testNotionLabel, testNotionButton, warningNotionLabel, warningNotionButton, contactNotionLabel, contactNotionButton, surveyRegisterLabel, surveyRegisterButton, surveyLabel, surveyButton, warningLogOutLabel, logOutButton]
        
        for newView in views {
            view.addSubview(newView)
            newView.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    // MARK: - @objc Method
    // '사용방법' 노션 페이지 버튼을 눌렀을 때 앱 내에서 페이지를 띄우는 메소드
    @objc private func pressTestNotionButton() {
        let testNotionAlert = UIAlertController(title: "페이지를 여시겠습니까?", message: nil, preferredStyle: .alert)
        let cancelButton = UIAlertAction(title: "취소", style: .cancel)
        let okButton = UIAlertAction(title: "확인", style: .default) { _ in
            if let testNotionURL = NSURL(string: "https://potent-barnacle-025.notion.site/bc2c2486ad7b4cfa94823e303082abca") {
                let testNotionView: SFSafariViewController = SFSafariViewController(url: testNotionURL as URL)
                self.present(testNotionView, animated: true, completion: nil)
            }
            
        }
        testNotionAlert.addAction(cancelButton)
        testNotionAlert.addAction(okButton)
        self.present(testNotionAlert, animated: true, completion: nil)
    }
    
    // '주의사항' 노션 페이지 버튼을 눌렀을 때 앱 내에서 페이지를 띄우는 메소드
    @objc private func pressWarningNotionButton() {
        let warningNotionAlert = UIAlertController(title: "페이지를 여시겠습니까?", message: nil, preferredStyle: .alert)
        let cancelButton = UIAlertAction(title: "취소", style: .cancel)
        let okButton = UIAlertAction(title: "확인", style: .default) { _ in
            if let warningNotionURL = NSURL(string: "https://potent-barnacle-025.notion.site/3af5727fddf149f09a56bfa624d9ef15") {
                let warningNotionView: SFSafariViewController = SFSafariViewController(url: warningNotionURL as URL)
                self.present(warningNotionView, animated: true, completion: nil)
            }
            
        }
        warningNotionAlert.addAction(cancelButton)
        warningNotionAlert.addAction(okButton)
        self.present(warningNotionAlert, animated: true, completion: nil)
    }
    
    // '문의사항' 노션 페이지 버튼을 눌렀을 때 앱 내에서 페이지를 띄우는 메소드
    @objc private func pressContactNotionButton() {
        let contactNotionAlert = UIAlertController(title: "페이지를 여시겠습니까?", message: nil, preferredStyle: .alert)
        let cancelButton = UIAlertAction(title: "취소", style: .cancel)
        let okButton = UIAlertAction(title: "확인", style: .default) { _ in
            if let contactNotionURL = NSURL(string: "https://potent-barnacle-025.notion.site/71828069ba564a4b876991c1610f161e") {
                let contactNotionView: SFSafariViewController = SFSafariViewController(url: contactNotionURL as URL)
                self.present(contactNotionView, animated: true, completion: nil)
            }
        }
        contactNotionAlert.addAction(cancelButton)
        contactNotionAlert.addAction(okButton)
        self.present(contactNotionAlert, animated: true, completion: nil)
    }
    
    // 설문조사 회원가입 버튼을 눌렀을 때 앱 내에서 페이지를 띄우는 메소드
    @objc private func pressSurveyRegisterButton() {
        let surveyAlert = UIAlertController(title: "페이지를 여시겠습니까?", message: nil, preferredStyle: .alert)
        let cancelButton = UIAlertAction(title: "취소", style: .cancel)
        let okButton = UIAlertAction(title: "확인", style: .default) { _ in
            if let surveyRegisterURL = NSURL(string: "http://114.71.220.59:2017/register") {
                let surveyRegisterView: SFSafariViewController = SFSafariViewController(url: surveyRegisterURL as URL)
                self.present(surveyRegisterView, animated: true, completion: nil)
            }
        }
        surveyAlert.addAction(cancelButton)
        surveyAlert.addAction(okButton)
        self.present(surveyAlert, animated: true, completion: nil)
    }
    
    // 설문조사 페이지 버튼을 눌렀을 때 앱 내에서 페이지를 띄우는 메소드
    @objc private func pressSurveyButton() {
        let surveyAlert = UIAlertController(title: "페이지를 여시겠습니까?", message: nil, preferredStyle: .alert)
        let cancelButton = UIAlertAction(title: "취소", style: .cancel)
        let okButton = UIAlertAction(title: "확인", style: .default) { _ in
            if let surveyURL = NSURL(string: "http://114.71.220.59:2017/") {
                let surveyView: SFSafariViewController = SFSafariViewController(url: surveyURL as URL)
                self.present(surveyView, animated: true, completion: nil)
            }
        }
        surveyAlert.addAction(cancelButton)
        surveyAlert.addAction(okButton)
        self.present(surveyAlert, animated: true, completion: nil)
    }
    
    // 로그아웃 버튼을 누를 때 실행되는 메소드
    @objc private func pressLogOutButton() {
        let logOutAlert = UIAlertController(title: "로그아웃 하시겠습니까?", message: "로그아웃하면 데이터를 수집할 수 없습니다!", preferredStyle: .alert)
        let cancelButton = UIAlertAction(title: "취소", style: .cancel)
        let checkButton = UIAlertAction(title: "확인", style: .default) { _ in
            let checkOneMoreAlert = UIAlertController(title: "정말 로그아웃 하시겠습니까?", message: "로그아웃은 ID를 바꿀 때만 실행해주세요.", preferredStyle: .alert)
            let cancelButton = UIAlertAction(title: "취소", style: .cancel)
            let checkButton = UIAlertAction(title: "로그아웃", style: .destructive) { _ in
                UserDefaults.standard.setValue(0, forKey: "appAuthorization")
                UserDefaults.standard.setValue("", forKey: "ID")
                UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    exit(0)
                }
            }
            checkOneMoreAlert.addAction(cancelButton)
            checkOneMoreAlert.addAction(checkButton)
            self.present(checkOneMoreAlert, animated: true, completion: nil)
        }
        logOutAlert.addAction(cancelButton)
        logOutAlert.addAction(checkButton)
        self.present(logOutAlert, animated: true, completion: nil)
    }
    
}
