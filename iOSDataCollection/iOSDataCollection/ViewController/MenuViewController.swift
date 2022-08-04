//
//  MenuViewController.swift
//  iOSDataCollection
//
//  Created by ROLF J. on 2022/08/02.
//

import UIKit

class MenuViewController: UIViewController {
    
    // MARK: - Instance member
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
        
        logOutButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
            make.centerX.equalToSuperview()
            make.width.equalTo(view.frame.width/4)
            make.height.equalTo(40)
        }
        logOutButton.addTarget(self, action: #selector(pressLogOutButton), for: .touchUpInside)
    }
    
    // AddSubView를 한 번에 실시
    private func addSubViews() {
        let views = [logOutButton]
        
        for newView in views {
            view.addSubview(newView)
            newView.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    // MARK: - @objc Method
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
