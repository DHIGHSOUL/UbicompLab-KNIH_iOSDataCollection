//
//  MainViewController.swift
//  iOSDataCollection
//
//  Created by ROLF J. on 2022/07/25.
//

import UIKit
import SnapKit
import RealmSwift

class MainViewController: UIViewController {
    
    // Singletone
    static let shared = MainViewController()
    
    // Main View의 TextField에 값을 지속적으로 표시하기 위한 Timer와 Interval
    var showAccelerationAndRotationTimer = Timer()
    var showAltitudeAndPressureTimer = Timer()
    let showAccelerationAndRotationInterval = 0.1
    let showAltitudeAndPressureInterval = 1.0
    
    // MARK: - Instance member
    // 가속도 표시 변수
    private let accelerationXLabel: UILabel = {
        let label = UILabel()
        label.text = "가속도 X값"
        
        return label
    }()
    private var showAccelerationXTextField = UITextField()
    private let accelerationYLabel: UILabel = {
        let label = UILabel()
        label.text = "가속도 Y값"
        
        return label
    }()
    private var showAccelerationYTextField = UITextField()
    private let accelerationZLabel: UILabel = {
        let label = UILabel()
        label.text = "가속도 Z값"
        
        return label
    }()
    private var showAccelerationZTextField = UITextField()
    
    // 회전속도 표시 변수
    private let rotationXLabel: UILabel = {
        let label = UILabel()
        label.text = "각속도 X값"
        
        return label
    }()
    private var showRotationXTextField = UITextField()
    private let rotationYLabel: UILabel = {
        let label = UILabel()
        label.text = "각속도 Y값"
        
        return label
    }()
    private var showRotationYTextField = UITextField()
    private let rotationZLabel: UILabel = {
        let label = UILabel()
        label.text = "각속도 Z값"
        
        return label
    }()
    private var showRotationZTextField = UITextField()
    
    // 고도/기압/절대고도 표시 변수
    private let altitudeLabel: UILabel = {
        let label = UILabel()
        label.text = "고도값"
        
        return label
    }()
    private var showAltitudeTextField = UITextField()
    private let pressureLabel: UILabel = {
        let label = UILabel()
        label.text = "기압"
        
        return label
    }()
    private var showPressureTextField = UITextField()
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        makeRealm()
        mainViewLayout()
        showSensorDatas()
    }
    
    // MARK: - Method
    // 파일을 저장한 번호를 추적하기 위한 인덱스를 저장하는 Realm 라이브러리 생성
    private func makeRealm() {
        _ = try! Realm()
        
        print(Realm.Configuration.defaultConfiguration.fileURL!)
    }
    
    // Main View의 Layout 지정
    private func mainViewLayout() {
        addViewsInMainView()
        textFieldSetting()
        showAccelerationInViews()
        showRotationInViews()
        showAltitudeInViews()
        showPressureInViews()
    }
    
    // AddSubView를 한 번에 실시
    private func addViewsInMainView() {
        let mainViews = [accelerationXLabel, accelerationYLabel, accelerationZLabel, showAccelerationXTextField, showAccelerationYTextField, showAccelerationZTextField, rotationXLabel, rotationYLabel, rotationZLabel, showRotationXTextField, showRotationYTextField, showRotationZTextField, altitudeLabel, showAltitudeTextField, pressureLabel, showPressureTextField]
        
        for newView in mainViews {
            view.addSubview(newView)
            newView.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    // textField들의 설정 한 번에 실시
    private func textFieldSetting() {
        let textFields = [showAccelerationXTextField, showAccelerationYTextField, showAccelerationZTextField, showRotationXTextField, showRotationYTextField, showRotationZTextField, showAltitudeTextField, showPressureTextField]
        
        for field in textFields {
            field.textColor = .black
            field.backgroundColor = .white
            field.clipsToBounds = false
            field.isUserInteractionEnabled = false
            
        }
    }
    
    // 가속도 관련 View들의 위치 결정
    private func showAccelerationInViews() {
        accelerationXLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.centerX.equalTo((view.frame.width/4))
        }
        showAccelerationXTextField.snp.makeConstraints { make in
            make.top.equalTo(accelerationXLabel.snp.bottom).offset(10)
            make.centerX.equalTo(accelerationXLabel.snp.centerX)
            make.width.equalTo(90)
            make.height.equalTo(30)
        }
        accelerationYLabel.snp.makeConstraints { make in
            make.top.equalTo(showAccelerationXTextField.snp.bottom).offset(20)
            make.centerX.equalTo(showAccelerationXTextField.snp.centerX)
        }
        showAccelerationYTextField.snp.makeConstraints { make in
            make.top.equalTo(accelerationYLabel.snp.bottom).offset(10)
            make.centerX.equalTo(accelerationYLabel.snp.centerX)
            make.width.equalTo(90)
            make.height.equalTo(30)
        }
        accelerationZLabel.snp.makeConstraints { make in
            make.top.equalTo(showAccelerationYTextField.snp.bottom).offset(20)
            make.centerX.equalTo(showAccelerationYTextField.snp.centerX)
        }
        showAccelerationZTextField.snp.makeConstraints { make in
            make.top.equalTo(accelerationZLabel.snp.bottom).offset(10)
            make.centerX.equalTo(accelerationZLabel.snp.centerX)
            make.width.equalTo(90)
            make.height.equalTo(30)
        }
    }
    
    // 회전속도 관련 View들의 위치 결정
    private func showRotationInViews() {
        rotationXLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.centerX.equalTo((view.frame.width/1.3))
        }
        showRotationXTextField.snp.makeConstraints { make in
            make.top.equalTo(rotationXLabel.snp.bottom).offset(10)
            make.centerX.equalTo(rotationXLabel.snp.centerX)
            make.width.equalTo(90)
            make.height.equalTo(30)
        }
        rotationYLabel.snp.makeConstraints { make in
            make.top.equalTo(showRotationXTextField.snp.bottom).offset(20)
            make.centerX.equalTo(showRotationXTextField.snp.centerX)
        }
        showRotationYTextField.snp.makeConstraints { make in
            make.top.equalTo(rotationYLabel.snp.bottom).offset(10)
            make.centerX.equalTo(rotationYLabel.snp.centerX)
            make.width.equalTo(90)
            make.height.equalTo(30)
        }
        rotationZLabel.snp.makeConstraints { make in
            make.top.equalTo(showRotationYTextField.snp.bottom).offset(20)
            make.centerX.equalTo(showRotationYTextField.snp.centerX)
        }
        showRotationZTextField.snp.makeConstraints { make in
            make.top.equalTo(rotationZLabel.snp.bottom).offset(10)
            make.centerX.equalTo(rotationZLabel.snp.centerX)
            make.width.equalTo(90)
            make.height.equalTo(30)
        }
    }
    
    // 고도 관련 View들의 위치 결정
    private func showAltitudeInViews() {
        altitudeLabel.snp.makeConstraints { make in
            make.top.equalTo(showAccelerationZTextField.snp.bottom).offset(20)
            make.centerX.equalTo(showAccelerationZTextField.snp.centerX)
        }
        showAltitudeTextField.snp.makeConstraints { make in
            make.top.equalTo(altitudeLabel.snp.bottom).offset(10)
            make.centerX.equalTo(altitudeLabel.snp.centerX)
            make.width.equalTo(90)
            make.height.equalTo(30)
        }
    }
    
    // 기압 관련 View들의 위치 결정
    private func showPressureInViews() {
        pressureLabel.snp.makeConstraints { make in
            make.top.equalTo(showRotationZTextField.snp.bottom).offset(20)
            make.centerX.equalTo(showRotationZTextField)
        }
        showPressureTextField.snp.makeConstraints { make in
            make.top.equalTo(pressureLabel.snp.bottom).offset(10)
            make.centerX.equalTo(pressureLabel.snp.centerX)
            make.width.equalTo(90)
            make.height.equalTo(30)
        }
    }
    
    // 센서에서 값을 받아와서 textField들에 뿌려주는 메소드
    private func showSensorDatas() {
        showAccelerationAndRotationTimer = Timer.scheduledTimer(timeInterval: showAccelerationAndRotationInterval, target: self, selector: #selector(showAccelerationAndRotationData), userInfo: nil, repeats: true)
        showAltitudeAndPressureTimer = Timer.scheduledTimer(timeInterval: showAltitudeAndPressureInterval, target: self, selector: #selector(showAltitudeAndPressureData), userInfo: nil, repeats: true)
    }
    
    // MARK: - @objc Method
    // 가속도, 각속도 측정값 표시 메소드
    @objc private func showAccelerationAndRotationData() {
        showAccelerationXTextField.text = DataCollectionManager.shared.newAccelerationXData
        showAccelerationYTextField.text = DataCollectionManager.shared.newAccelerationYData
        showAccelerationZTextField.text = DataCollectionManager.shared.newAccelerationZData
        showRotationXTextField.text = DataCollectionManager.shared.newRotationXData
        showRotationYTextField.text = DataCollectionManager.shared.newRotationYData
        showRotationZTextField.text = DataCollectionManager.shared.newRotationZData
    }
    
    // 고도, 기압 측정값 표시 준비 메소드
    @objc private func showAltitudeAndPressureData() {
        showAltitudeTextField.text = DataCollectionManager.shared.newAltitudeData
        showPressureTextField.text = DataCollectionManager.shared.newPressureData
    }
    
}
