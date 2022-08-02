//
//  UserInfoViewController.swift
//  iOSDataCollection
//
//  Created by ROLF J. on 2022/08/01.
//

import UIKit

class UserInfoViewController: UIViewController {
    
    // MARK: - Instance member
    // SCH 로고
    private let schLogoImageView: UIImageView = {
        let view = UIImageView()
        view.clipsToBounds = true
        view.image = UIImage(named: "SCHLogo")
        view.contentMode = .scaleAspectFit
        
        return view
    }()
    
    // 유저번호 입력 유도 Label
    private let userIDLabel: UILabel = {
        let label = UILabel()
        label.text = "전달받은 ID 3자리를 입력해주세요! (예: 001)"
        label.textColor = .white
        
        return label
    }()
    
    // User ID를 입력받을 TextField
    let userIDTextField: UITextField = {
        let field = UITextField()
        field.backgroundColor = .white
        field.textColor = .black
        field.textAlignment = .center
        
        return field
    }()
    
    // 저장하기 버튼
    let saveIDButton: UIButton = {
        let button = UIButton()
        button.clipsToBounds = true
        button.setTitle("저장하기", for: .normal)
        var buttonConfiguration = UIButton.Configuration.filled()
        buttonConfiguration.baseBackgroundColor = .systemBlue
        buttonConfiguration.baseForegroundColor = .white
        button.configuration = buttonConfiguration
        
        return button
    }()
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userInfoViewLayout()
    }
    
    // MARK: - Method
    // User Info View의 Layout 지정
    private func userInfoViewLayout() {
        view.backgroundColor = .black
        
        addViewsInUserInfoView()
        
        schLogoImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.width.equalTo(view)
            make.height.equalTo(100)
        }
        
        userIDTextField.snp.makeConstraints { make in
            make.center.equalTo(view)
            make.leading.equalTo(view.frame.width/3)
            make.trailing.equalTo(-(view.frame.width/3))
            make.height.equalTo(50)
        }
        
        userIDLabel.snp.makeConstraints { make in
            make.bottom.equalTo(userIDTextField.snp.top).offset(-10)
            make.centerX.equalTo(view)
        }
        
        saveIDButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.leading.equalTo(view.frame.width/3)
            make.trailing.equalTo(-(view.frame.width/3))
            make.height.equalTo(40)
        }
        saveIDButton.addTarget(self, action: #selector(pressSaveUserIDButton), for: .touchUpInside)
    }
    
    // AddSubView를 한 번에 실시
    private func addViewsInUserInfoView() {
        let views = [schLogoImageView, userIDLabel, userIDTextField, saveIDButton]
        
        for newView in views {
            view.addSubview(newView)
            newView.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    // 사용자가 입력 ID가 규정에 맞는지 체크하는 메소드
    private func checkUserID() -> Bool {
        let enteredID = userIDTextField.text
        
        // 입력된 번호 길이가 3자리가 아니거나, 숫자가 아니라면 오류
        if Int(enteredID ?? "오류") == nil {
            let noNumberAlert = UIAlertController(title: "ID는 숫자만 입력되어야 합니다!", message: "다시 입력해주세요!", preferredStyle: .alert)
            let checkButton = UIAlertAction(title: "확인", style: .default) {_ in
                self.userIDTextField.text = ""
            }
            noNumberAlert.addAction(checkButton)
            present(noNumberAlert, animated: true, completion: nil)
            
            return false
        } else if (enteredID ?? "오류").count != 3 {
            let lengthErrorAlert = UIAlertController(title: "ID 길이는 3자리입니다!", message: "다시 입력해주세요!", preferredStyle: .alert)
            let checkButton = UIAlertAction(title: "확인", style: .default) {_ in
                self.userIDTextField.text = ""
            }
            lengthErrorAlert.addAction(checkButton)
            present(lengthErrorAlert, animated: true, completion: nil)
            
            return false
        }
        
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // MARK: - @objc Method
    // 저장하기 버튼을 눌러 User ID를 UserDefaults에 저장하고 앱을 재시작시키는 메소드
    @objc private func pressSaveUserIDButton() {
        print(UserDefaults.standard.integer(forKey: "appAuthorization"))
        
        if checkUserID() == true {
            UserDefaults.standard.setValue("S\(userIDTextField.text!)", forKey: "ID")
            print("User ID = \(String(describing: UserDefaults.standard.string(forKey: "ID")))")
            UserDefaults.standard.setValue(1, forKey: "appAuthorization")
            
            print(UserDefaults.standard.integer(forKey: "appAuthorization"))
            
            if UserDefaults.standard.integer(forKey: "appAuthorization") == 1 {
                let successAlert = UIAlertController(title: "저장되었습니다!", message: "앱이 꺼집니다. 종료 후 앱을 재시작해주세요!", preferredStyle: .alert)
                let checkButton = UIAlertAction(title: "확인", style: .default) {_ in
                    UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        exit(0)
                    }
                }
                successAlert.addAction(checkButton)
                present(successAlert, animated: true, completion: nil)
            }
        }
    }
    
}
