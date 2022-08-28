//
//  MenuViewController.swift
//  iOSDataCollection
//
//  Created by ROLF J. on 2022/08/02.
//

import UIKit
import SafariServices
import RealmSwift
import NVActivityIndicatorView

class MenuViewController: UIViewController {
    
    static let shared = MenuViewController()
    
    // MARK: - Instance member
    // 10시 즈음에 업로드 상태를 업로드할 타이머
    var checkUploadTimer = Timer()
    
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
        label.text = LanguageChange.MenuViewWord.whatToDoLabel
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 13)
        label.textAlignment = .center
        
        return label
    }()
    
    // '사용방법' 노션 페이지로 이동하는 버튼
    private let testNotionButton: UIButton = {
        let button = UIButton()
        button.clipsToBounds = true
        button.setTitle(LanguageChange.MenuViewWord.whatToDoButton, for: .normal)
        var buttonConfiguration = UIButton.Configuration.filled()
        buttonConfiguration.baseBackgroundColor = .darkGray
        buttonConfiguration.baseForegroundColor = .white
        button.configuration = buttonConfiguration
        
        return button
    }()
    
    // '주의사항' 노션으로 이동하는 것을 알리는 Label
    private let warningNotionLabel: UILabel = {
        let label = UILabel()
        label.text = LanguageChange.MenuViewWord.precautionLabel
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 13)
        label.textAlignment = .center
        
        return label
    }()
    
    // '주의사항' 노션 페이지로 이동하는 버튼
    private let warningNotionButton: UIButton = {
        let button = UIButton()
        button.clipsToBounds = true
        button.setTitle(LanguageChange.MenuViewWord.precautionButton, for: .normal)
        var buttonConfiguration = UIButton.Configuration.filled()
        buttonConfiguration.baseBackgroundColor = .darkGray
        buttonConfiguration.baseForegroundColor = .white
        button.configuration = buttonConfiguration
        
        return button
    }()
    
    // '문의사항' 노션으로 이동하는 것을 알리는 Label
    private let contactNotionLabel: UILabel = {
        let label = UILabel()
        label.text = LanguageChange.MenuViewWord.contactLabel
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 13)
        label.textAlignment = .center
        
        return label
    }()
    
    // '문의사항' 노션 페이지로 이동하는 버튼
    private let contactNotionButton: UIButton = {
        let button = UIButton()
        button.clipsToBounds = true
        button.setTitle(LanguageChange.MenuViewWord.contactButton, for: .normal)
        var buttonConfiguration = UIButton.Configuration.filled()
        buttonConfiguration.baseBackgroundColor = .darkGray
        buttonConfiguration.baseForegroundColor = .white
        button.configuration = buttonConfiguration
        
        return button
    }()
    
    // 설문조사 가입 페이지로 이동하는 것을 알리는 Label
    private let surveyRegisterLabel: UILabel = {
        let label = UILabel()
        label.text = LanguageChange.MenuViewWord.registerLabel
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 13)
        label.textAlignment = .center
        
        return label
    }()
    
    // 설문조사 회원가입 페이지로 이동하는 버튼
    private let surveyRegisterButton: UIButton = {
        let button = UIButton()
        button.clipsToBounds = true
        button.setTitle(LanguageChange.MenuViewWord.registerButton, for: .normal)
        var buttonConfiguration = UIButton.Configuration.filled()
        buttonConfiguration.baseBackgroundColor = .darkGray
        buttonConfiguration.baseForegroundColor = .white
        button.configuration = buttonConfiguration
        
        return button
    }()
    
    // 설문조사 페이지로 이동하는 것을 알리는 Label
    private let surveyLabel: UILabel = {
        let label = UILabel()
        label.text = LanguageChange.MenuViewWord.surveyLabel
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 13)
        label.textAlignment = .center
        
        return label
    }()
    
    // 설문조사 페이지로 이동하는 버튼
    private let surveyButton: UIButton = {
        let button = UIButton()
        button.clipsToBounds = true
        button.setTitle(LanguageChange.MenuViewWord.surveyButton, for: .normal)
        var buttonConfiguration = UIButton.Configuration.filled()
        buttonConfiguration.baseBackgroundColor = .darkGray
        buttonConfiguration.baseForegroundColor = .white
        button.configuration = buttonConfiguration
        
        return button
    }()
    
    // Health Data 업로드 상태를 나타낼 Label
    private let healthDataLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textAlignment = .center
        
        return label
    }()
    
    // 건강 데이터 업로드 버튼
    private let uploadDataButton: UIButton = {
        let button = UIButton()
        button.clipsToBounds = true
        
        return button
    }()
    
    // 로그아웃 경고를 나타낼 Label
    private let warningLogOutLabel: UILabel = {
        let label = UILabel()
        label.text = LanguageChange.MenuViewWord.logOutWarning
        label.textColor = .systemRed
        label.font = UIFont.systemFont(ofSize: 13)
        label.textAlignment = .center
        
        return label
    }()
    
    // 로그아웃 버튼
    private let logOutButton: UIButton = {
        let button = UIButton()
        button.clipsToBounds = true
        button.setTitle(LanguageChange.MenuViewWord.logOutButton, for: .normal)
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        isUploadedToday()
    }
    
    // MARK: - Method
    // Menu View의 레이아웃 설정
    private func menuViewLayout() {
        addSubViews()
        
//        if UserDefaults.standard.value(forKey: "AppleLanguages")
        
        userIDLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(-40)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(20)
        }
        
        testNotionLabel.snp.makeConstraints { make in
            make.top.equalTo(userIDLabel.snp.bottom).offset(15)
            make.width.equalTo(view)
        }
        
        testNotionButton.snp.makeConstraints { make in
            make.top.equalTo(testNotionLabel.snp.bottom).offset(5)
            make.width.equalToSuperview()
            make.height.equalTo(40)
        }
        testNotionButton.addTarget(self, action: #selector(pressTestNotionButton), for: .touchUpInside)
        
        warningNotionLabel.snp.makeConstraints { make in
            make.top.equalTo(testNotionButton.snp.bottom).offset(15)
            make.width.equalTo(view)
        }
        
        warningNotionButton.snp.makeConstraints { make in
            make.top.equalTo(warningNotionLabel.snp.bottom).offset(5)
            make.width.equalToSuperview()
            make.height.equalTo(40)
        }
        warningNotionButton.addTarget(self, action: #selector(pressWarningNotionButton), for: .touchUpInside)
        
        contactNotionLabel.snp.makeConstraints { make in
            make.top.equalTo(warningNotionButton.snp.bottom).offset(15)
            make.width.equalTo(view)
        }
        
        contactNotionButton.snp.makeConstraints { make in
            make.top.equalTo(contactNotionLabel.snp.bottom).offset(5)
            make.width.equalToSuperview()
            make.height.equalTo(40)
        }
        contactNotionButton.addTarget(self, action: #selector(pressContactNotionButton), for: .touchUpInside)
        
        surveyRegisterLabel.snp.makeConstraints { make in
            make.top.equalTo(contactNotionButton.snp.bottom).offset(15)
            make.width.equalTo(view)
        }
        
        surveyRegisterButton.snp.makeConstraints { make in
            make.top.equalTo(surveyRegisterLabel.snp.bottom).offset(5)
            make.width.equalToSuperview()
            make.height.equalTo(40)
        }
        surveyRegisterButton.addTarget(self, action: #selector(pressSurveyRegisterButton), for: .touchUpInside)
        
        surveyLabel.snp.makeConstraints { make in
            make.top.equalTo(surveyRegisterButton.snp.bottom).offset(15)
            make.width.equalTo(view)
        }
        
        surveyButton.snp.makeConstraints { make in
            make.top.equalTo(surveyLabel.snp.bottom).offset(5)
            make.width.equalToSuperview()
            make.height.equalTo(40)
        }
        surveyButton.addTarget(self, action: #selector(pressSurveyButton), for: .touchUpInside)
        
        healthDataLabel.snp.makeConstraints { make in
            make.top.equalTo(surveyButton.snp.bottom).offset(15)
            make.width.equalToSuperview()
        }
        
        uploadDataButton.snp.makeConstraints { make in
            make.top.equalTo(healthDataLabel.snp.bottom).offset(5)
            make.width.equalToSuperview()
            make.height.equalTo(40)
        }
        uploadDataButton.addTarget(self, action: #selector(pressUploadDataButton), for: .touchUpInside)
        
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
        let views = [userIDLabel, testNotionLabel, testNotionButton, warningNotionLabel, warningNotionButton, contactNotionLabel, contactNotionButton, surveyRegisterLabel, surveyRegisterButton, surveyLabel, surveyButton, healthDataLabel, uploadDataButton, warningLogOutLabel, logOutButton]
        
        for newView in views {
            view.addSubview(newView)
            newView.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    // 오늘이 앱 시작일인지 파악하는 메소드
    func checkAppStartDay() -> Bool {
        let calendar = Calendar.current
        let checkAppStartDateString = Double(UserDefaults.standard.string(forKey: "appStartDate") ?? "appStartDateError") ?? 0.0
        let checkAppStartDate = Date(timeIntervalSince1970: checkAppStartDateString)
        print("App start date is \(checkAppStartDate), and it's \(calendar.isDateInToday(checkAppStartDate))")
        if calendar.isDateInToday(checkAppStartDate) {
            print("Today is app start date. Health query will set since tomorrow")
            return true
        }
        
        return false
    }
    
    // 버튼을 눌렀을 때 10시 이후인지 확인하는 메소드
    func isAfterTen() {
        let realm = try! Realm()
        let lastIndex = HealthDataManager.shared.getLastIndexOfHealthRealm()
        
        let now = Date()
        let nowUnixTime = now.timeIntervalSince1970
        let nowTen = Calendar.current.date(bySettingHour: 10, minute: 00, second: 00, of: now)
        let nowTenUnixTime = nowTen?.timeIntervalSince1970
        
        print(now)
        print(nowTen!)
        
        // 첫 다음 날에 10시 이전 데이터를 업로드를 하려는 것을 막는 조건(해당 날짜의 10시 이전에는 업로드 불가)
        if lastIndex == 0 {
            if nowUnixTime > nowTenUnixTime! {
                UserDefaults.standard.setValue(false, forKey: "todayUploadState")
                return
            } else {
                UserDefaults.standard.setValue(true, forKey: "todayUploadState")
                return
            }
        }
        
        let checkRealm = realm.object(ofType: HealthRealmManager.self, forPrimaryKey: lastIndex)
        let yesterDayUploadUnixTimeString = checkRealm?.saveUnixTime
        let yesterDayUploadUnixTime = Double(yesterDayUploadUnixTimeString ?? "GetLastIndexUnixTimeError")
        let yesterDayUploadTime = Date(timeIntervalSince1970: yesterDayUploadUnixTime!)
        let todayCanUploadDate = Calendar.current.date(byAdding: .day, value: 2, to: yesterDayUploadTime)
        let todayCanUploadTime = Calendar.current.date(bySettingHour: 10, minute: 00, second: 00, of: todayCanUploadDate!)
        let todayCanUploadUnixTime = todayCanUploadTime?.timeIntervalSince1970
        
        print("now = \(now)")
        print("TodayCanUploadTime = \(todayCanUploadTime!)")

        if nowUnixTime > todayCanUploadUnixTime! {
            UserDefaults.standard.setValue(false, forKey: "todayUploadState")
        } else {
            UserDefaults.standard.setValue(true, forKey: "todayUploadState")
        }
    }
    
    // 오늘 업로드 상태를 파악하고 업로드 상태 라벨을 변경하는 메소드
    func isUploadedToday() {
        let checkUpload = UserDefaults.standard.bool(forKey: "todayUploadState")
        
        if checkUpload == true {
            var buttonConfiguration = UIButton.Configuration.filled()
            buttonConfiguration.baseBackgroundColor = .darkGray
            buttonConfiguration.baseForegroundColor = .white
            uploadDataButton.configuration = buttonConfiguration
            uploadDataButton.setTitle(LanguageChange.MenuViewWord.uploadDataButton, for: .normal)
            healthDataLabel.textColor = .lightGray
            healthDataLabel.text = LanguageChange.MenuViewWord.uploadCompleted
        } else {
            var buttonConfiguration = UIButton.Configuration.filled()
            buttonConfiguration.baseBackgroundColor = .systemPink
            buttonConfiguration.baseForegroundColor = .white
            uploadDataButton.configuration = buttonConfiguration
            uploadDataButton.setTitle(LanguageChange.MenuViewWord.uploadDataButton, for: .normal)
            healthDataLabel.textColor = .systemPink
            healthDataLabel.text = LanguageChange.MenuViewWord.notYetUploaded
        }
    }
    
    // 오늘 업로드가 완료되었는지 매일 00시에 확인하는 메소드
    func checkUploadState() {
        let now = Date()
        let checkTime = Calendar.current.date(bySettingHour: 10, minute: 00, second: 03, of: now)!
        checkUploadTimer = Timer.init(fireAt: checkTime, interval: 86400, target: self, selector: #selector(checkTodayUploadState), userInfo: nil, repeats: true)
    }
    
    // MARK: - @objc Method
    // '사용방법' 노션 페이지 버튼을 눌렀을 때 앱 내에서 페이지를 띄우는 메소드
    @objc private func pressTestNotionButton() {
        let testNotionAlert = UIAlertController(title: LanguageChange.AlertWord.wantToOpenWeb, message: nil, preferredStyle: .alert)
        let cancelButton = UIAlertAction(title: LanguageChange.AlertWord.alertCancel, style: .cancel)
        let okButton = UIAlertAction(title: LanguageChange.AlertWord.alertConfirm, style: .default) { _ in
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
        let warningNotionAlert = UIAlertController(title: LanguageChange.AlertWord.wantToOpenWeb, message: nil, preferredStyle: .alert)
        let cancelButton = UIAlertAction(title: LanguageChange.AlertWord.alertCancel, style: .cancel)
        let okButton = UIAlertAction(title: LanguageChange.AlertWord.alertConfirm, style: .default) { _ in
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
        let contactNotionAlert = UIAlertController(title: LanguageChange.AlertWord.wantToOpenWeb, message: nil, preferredStyle: .alert)
        let cancelButton = UIAlertAction(title: LanguageChange.AlertWord.alertCancel, style: .cancel)
        let okButton = UIAlertAction(title: LanguageChange.AlertWord.alertConfirm, style: .default) { _ in
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
        let surveyAlert = UIAlertController(title: LanguageChange.AlertWord.wantToOpenWeb, message: nil, preferredStyle: .alert)
        let cancelButton = UIAlertAction(title: LanguageChange.AlertWord.alertCancel, style: .cancel)
        let okButton = UIAlertAction(title: LanguageChange.AlertWord.alertConfirm, style: .default) { _ in
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
        let surveyAlert = UIAlertController(title: LanguageChange.AlertWord.wantToOpenWeb, message: nil, preferredStyle: .alert)
        let cancelButton = UIAlertAction(title: LanguageChange.AlertWord.alertCancel, style: .cancel)
        let okButton = UIAlertAction(title: LanguageChange.AlertWord.alertConfirm, style: .default) { _ in
            if let surveyURL = NSURL(string: "http://114.71.220.59:2017/") {
                let surveyView: SFSafariViewController = SFSafariViewController(url: surveyURL as URL)
                self.present(surveyView, animated: true, completion: nil)
            }
        }
        surveyAlert.addAction(cancelButton)
        surveyAlert.addAction(okButton)
        self.present(surveyAlert, animated: true, completion: nil)
    }
    
    // 건강 데이터를 업로드하는 버튼 메소드
    @objc private func pressUploadDataButton() {
        let indicator = NVActivityIndicatorView(frame: CGRect(x: view.frame.midX - 50, y: view.frame.midY - 50, width: 100, height: 100), type: .ballSpinFadeLoader, color: .lightGray, padding: 0)
        view.addSubview(indicator)
        indicator.bounds = view.frame
        indicator.startAnimating()
        
        if checkAppStartDay() == true {
            indicator.stopAnimating()
            let appStartAlert = UIAlertController(title: LanguageChange.AlertWord.uploadTomorrow, message: nil, preferredStyle: .alert)
            let okButton = UIAlertAction(title: LanguageChange.AlertWord.alertConfirm, style: .default)
            appStartAlert.addAction(okButton)
            present(appStartAlert, animated: true, completion: nil)
            return
        }
        
        isAfterTen()
        let uploadAlreadyCompleted = UserDefaults.standard.bool(forKey: "todayUploadState")
        print("todayUploadState = \(uploadAlreadyCompleted)")
        if uploadAlreadyCompleted == true {
            indicator.stopAnimating()
            let alreadyUploadedAlert = UIAlertController(title: LanguageChange.AlertWord.alreadyUploaded, message: nil, preferredStyle: .alert)
            let okButton = UIAlertAction(title: LanguageChange.AlertWord.alertConfirm, style: .default)
            alreadyUploadedAlert.addAction(okButton)
            present(alreadyUploadedAlert, animated: true, completion: nil)
            return
        }
        
        if NetWorkManager.shared.isConnected == false {
            indicator.stopAnimating()
            let netWorkAlert = UIAlertController(title: LanguageChange.AlertWord.internetError, message: LanguageChange.AlertWord.internetErrorMessage, preferredStyle: .alert)
            let okButton = UIAlertAction(title: LanguageChange.AlertWord.alertConfirm, style: .default)
            netWorkAlert.addAction(okButton)
            present(netWorkAlert, animated: true, completion: nil)
            return
        }
        
        HealthDataManager.shared.makeHealthCSVFileAndUpload()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            indicator.stopAnimating()
            WindowTabBarViewController.shared.selectedIndex = 1
            self.isUploadedToday()
            let finishAlert = UIAlertController(title: LanguageChange.AlertWord.uploadComplete, message: nil, preferredStyle: .alert)
            let okButton = UIAlertAction(title: LanguageChange.AlertWord.alertConfirm, style: .default)
            finishAlert.addAction(okButton)
            self.present(finishAlert, animated: true, completion: nil)
        }
    }
    
    // 로그아웃 버튼을 누를 때 실행되는 메소드
    @objc private func pressLogOutButton() {
        let logOutAlert = UIAlertController(title: LanguageChange.AlertWord.wantToLogOut, message: LanguageChange.AlertWord.canNotCollectData, preferredStyle: .alert)
        let cancelButton = UIAlertAction(title: LanguageChange.AlertWord.alertCancel, style: .cancel)
        let checkButton = UIAlertAction(title: LanguageChange.AlertWord.alertConfirm, style: .default) { _ in
            let checkOneMoreAlert = UIAlertController(title: LanguageChange.AlertWord.reallySingOut, message: LanguageChange.AlertWord.signOutWhenYouChangeID, preferredStyle: .alert)
            let cancelButton = UIAlertAction(title: LanguageChange.AlertWord.alertCancel, style: .cancel)
            let checkButton = UIAlertAction(title: LanguageChange.AlertWord.alertLogOut, style: .destructive) { _ in
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
    
    // 오늘 업로드가 되었는지 파악하는 메소드
    @objc func checkTodayUploadState() {
        isUploadedToday()
    }
    
}
