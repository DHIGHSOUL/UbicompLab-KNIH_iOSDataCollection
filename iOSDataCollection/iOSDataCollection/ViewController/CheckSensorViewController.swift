//
//  CheckSensorViewController.swift
//  iOSDataCollection
//
//  Created by ROLF J. on 2022/07/25.
//

import UIKit
import CoreMotion

class CheckSensorViewController: UIViewController {
    
    static let shared = CheckSensorViewController()
    
    var checkComponentTimer = Timer()
    let checkComponentTimeInterval = 1.0
    var altitudeDataForCheckSensor = NSNumber()
    var pressureDataForCheckSensor = NSNumber()
    
    // MARK: - Instance member
    // 센서 정상 작동을 표시할 TextField(색만 사용할 예정)
    private let checkAccelerationLabel: UILabel = {
        let label = UILabel()
        label.text = "가속도계 작동여부"
        
        return label
    }()
    private var checkAcceleration = UITextField()
    private let checkGyroLabel: UILabel = {
        let label = UILabel()
        label.text = "각속도계 작동여부"
        
        return label
    }()
    private var checkGyro = UITextField()
    private let checkAltitudeLabel: UILabel = {
        let label = UILabel()
        label.text = "고도계 작동여부"
        
        return label
    }()
    private var checkAltitude = UITextField()
    private let checkPressureLabel: UILabel = {
        let label = UILabel()
        label.text = "기압계 작동여부"
        
        return label
    }()
    private var checkPressure = UITextField()
    private let checkInternetLabel: UILabel = {
        let label = UILabel()
        label.text = "인터넷 연결여부"
        
        return label
    }()
    private var checkInternet = UITextField()
    

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkSensorViewLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        checkSensorsWorking()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        checkComponentTimer.invalidate()
    }

    // MARK: - Method
    // Check Sensor View의 Layout 지정
    private func checkSensorViewLayout() {
        addViewsInMainView()
        textFieldSetting()
        componentsInView()
    }
    
    // AddSubView를 한 번에 실시
    private func addViewsInMainView() {
        let mainViews = [checkAccelerationLabel, checkAcceleration, checkGyroLabel, checkGyro, checkAltitudeLabel, checkAltitude, checkPressureLabel, checkPressure, checkInternetLabel, checkInternet]
        
        for newView in mainViews {
            view.addSubview(newView)
            view.translatesAutoresizingMaskIntoConstraints = false
            view.sizeToFit()
        }
    }
    
    // 색상을 표시할 TextField들의 설정
    private func textFieldSetting() {
        let textFields = [checkAcceleration, checkGyro, checkAltitude, checkPressure, checkInternet]
        
        for field in textFields {
            field.layer.cornerRadius = 20
            field.isUserInteractionEnabled = false
            field.backgroundColor = .systemRed
            field.clipsToBounds = true
        }
    }
    
    // 컴포넌트들의 위치를 지정
    private func componentsInView() {
        checkAccelerationLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.leading.equalTo(view.frame.width/3)
        }
        checkAcceleration.snp.makeConstraints { make in
            make.top.equalTo(checkAccelerationLabel.snp.bottom).offset(10)
            make.centerX.equalTo(checkAccelerationLabel)
            make.width.height.equalTo(40)
        }
        
        checkGyroLabel.snp.makeConstraints { make in
            make.top.equalTo(checkAcceleration.snp.bottom).offset(20)
            make.centerX.equalTo(checkAccelerationLabel)
        }
        checkGyro.snp.makeConstraints { make in
            make.top.equalTo(checkGyroLabel.snp.bottom).offset(10)
            make.centerX.equalTo(checkGyroLabel)
            make.width.height.equalTo(40)
        }
        
        checkAltitudeLabel.snp.makeConstraints { make in
            make.top.equalTo(checkGyro.snp.bottom).offset(20)
            make.centerX.equalTo(checkGyro)
        }
        checkAltitude.snp.makeConstraints { make in
            make.top.equalTo(checkAltitudeLabel.snp.bottom).offset(10)
            make.centerX.equalTo(checkAltitudeLabel)
            make.width.height.equalTo(40)
        }
        
        checkPressureLabel.snp.makeConstraints { make in
            make.top.equalTo(checkAltitude.snp.bottom).offset(20)
            make.centerX.equalTo(checkAltitude)
        }
        checkPressure.snp.makeConstraints { make in
            make.top.equalTo(checkPressureLabel.snp.bottom).offset(10)
            make.centerX.equalTo(checkPressureLabel.snp.centerX)
            make.width.height.equalTo(40)
        }
        
        checkInternetLabel.snp.makeConstraints { make in
            make.top.equalTo(checkPressure.snp.bottom).offset(20)
            make.centerX.equalTo(checkPressure)
        }
        checkInternet.snp.makeConstraints { make in
            make.top.equalTo(checkInternetLabel.snp.bottom).offset(10)
            make.centerX.equalTo(checkInternetLabel.snp.centerX)
            make.width.height.equalTo(40)
        }
    }
    
    // 센서가 작동하는지(1초마다 값이 이동하는지 확인)를 감지하고 textField에 색으로 표현
    private func checkSensorsWorking() {
        self.checkComponentTimer = Timer.scheduledTimer(timeInterval: checkComponentTimeInterval, target: self, selector: #selector(checkComponents), userInfo: nil, repeats: true)
    }
    
    // 고도, 기압계 센서 작동을 측정하기 위해 NSNumber 값을 가져오는 메소드
    func sensorDataForCheck(_ altimeter: CMAltitudeData) {
        altitudeDataForCheckSensor = altimeter.relativeAltitude
        pressureDataForCheckSensor = altimeter.pressure
    }
    
    // MARK: - @objc Method
    // 앱 내 컴포넌트들이 작동하는지 확인하는 메소드
    @objc func checkComponents() {
        
        print("Checking Components")
        
        if DataCollectionManager.shared.motionManager.isDeviceMotionAvailable == true {
            checkAcceleration.backgroundColor = .systemGreen
            checkGyro.backgroundColor = .systemGreen
        } else {
            checkAcceleration.backgroundColor = .systemRed
            checkGyro.backgroundColor = .systemRed
            print("Acclerator&Gyro Not Working!")
        }
        
        var oneSecondBeforeAltitudeData: NSNumber = 0.0
        var oneSecondBeforePressureData: NSNumber = 0.0
        
        let currentAltitudeData = altitudeDataForCheckSensor
        let currentPressureData = pressureDataForCheckSensor
        
        if oneSecondBeforeAltitudeData != currentAltitudeData {
            checkAltitude.backgroundColor = .systemGreen
        } else {
            checkAltitude.backgroundColor = .systemRed
            print("Altitude Not Working!")
        }
        
        if oneSecondBeforePressureData != currentPressureData {
            checkPressure.backgroundColor = .systemGreen
        } else {
            checkPressure.backgroundColor = .systemRed
            print("Pressure Not Working!")
            
            oneSecondBeforeAltitudeData = currentAltitudeData
            oneSecondBeforePressureData = currentPressureData
        }
        
        if NetWorkManager.shared.isConnected == true {
            checkInternet.backgroundColor = .systemGreen
        } else {
            checkInternet.backgroundColor = .systemRed
            print("No Internet Connection")
        }
        
    }
    
}
