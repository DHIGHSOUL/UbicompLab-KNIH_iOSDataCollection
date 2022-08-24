//
//  DataCollectionManager.swift
//  iOSDataCollection
//
//  Created by ROLF J. on 2022/07/25.
//

import Foundation
import CoreMotion
import RealmSwift

// 남은 측정시간을 표시하기 위한 변수
public var uploadTimeVariable = 600

class DataCollectionManager {
    
    static let shared = DataCollectionManager()
    
    // 앱 재시작 후의 잔여 파일을 감지하고 인터넷 연결을 지속적으로 체크하기 위한 타이머
    var restartAndCheckTimer = Timer()
    
    // 센서 측정값을 저장하는 변수
    var newAccelerationXData = String()
    var newAccelerationYData = String()
    var newAccelerationZData = String()
    var newRotationXData = String()
    var newRotationYData = String()
    var newRotationZData = String()
    var newAltitudeData = String()
    var newPressureData = String()
    
    // 센서 측정값을 CSV 파일에 저장하기 위해 String 형태로 만들어두기 위한 변수
    var accelerationDataString = ""
    var rotationDataString = ""
    var pressureDataString = ""
    
    // 파일을 저장할 때 인덱싱을 하기 위한 변수
    var indexCount: Int = 0
    
    // 센서 측정값을 임시로 저장하기 위한 배열
    var accelerationArray: [String] = []
    var rotationArray: [String] = []
    var pressureArray: [String] = []
    
    // MARK: - Instance member
    // 측정값 변수
    var motionManager = CMMotionManager()
    var altimeterManager = CMAltimeter()
    var currentRelativeAltitude = NSNumber()
    var currentPressure = NSNumber()
    
    // MARK: - Method
    // UnixTime을 가져오는 메소드
    public func getUnixTime() -> String {
        let nowUnixTime = Date().timeIntervalSince1970
        
        return String(Int(nowUnixTime))
    }
    
    // 데이터들을 관리하는 매니저 메소드
    func dataCollectionManagerMethod() {
        print("Start Data Collection")
        
        motionManager.accelerometerUpdateInterval = 1/15
        motionManager.gyroUpdateInterval = 1/15
        
        if let currentValue = OperationQueue.current {
            motionManager.startAccelerometerUpdates(to: currentValue, withHandler: {
                (accelerometerData: CMAccelerometerData!, error: Error!) -> Void in
                self.outputAccelerationData(accelerometerData.acceleration)
                if(error != nil) {
                    print("MotionManagerError = \(error!)")
                }
            })
            
            motionManager.startGyroUpdates(to: currentValue, withHandler: {
                (gyroData: CMGyroData!, error: Error!) -> Void in
                self.outputRotationData(gyroData.rotationRate)
                if(error != nil) {
                    print("GyroError = \(error!)")
                }
            })
            
            if CMAltimeter.isRelativeAltitudeAvailable() {
                altimeterManager.startRelativeAltitudeUpdates(to: currentValue, withHandler: {
                    (altimeterData: CMAltitudeData!, error: Error!) -> Void in
                    self.outputAtitudeData(altimeterData)
                    
                    if(error != nil) {
                        print("AltimeterError = \(error!)")
                    }
                })
            }
        }
        
        Timer.scheduledTimer(timeInterval: 600, target: self, selector: #selector(makeSensorCSVFileAndUpload), userInfo: nil, repeats: true)
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(uploadTimeLabelMethod), userInfo: nil, repeats: true)
    }
    
    // Sensor Realm의 마지막 인덱스를 읽어오는 메소드
    func getLastIndexOfSensorRealm() -> Int {
        let realm = try! Realm()
        let getRealm = realm.objects(SensorRealmManager.self)
        let getLastIndex = getRealm.endIndex
        
        return getLastIndex
    }
    
    // 앱 재시작 시(checkWhenReStart), 센서 데이터 파일이 남아 있다면 인터넷 연결을 체크하고 남은 파일을 한번에 업로드함
    func checkAndReUploadSensorFiles() {
        if checkWhenReStartSensorDatas() != 0 {
            restartAndCheckTimer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(reuploadFiles), userInfo: nil, repeats: true)
        }
    }
    
    // 가속도 측정값을 출력(print)하는 메소드
    private func outputAccelerationData(_ acceleration: CMAcceleration) {
        let accX = String(format: "%.3f", arguments: [acceleration.x])
        let accY = String(format: "%.3f", arguments: [acceleration.y])
        let accZ = String(format: "%.3f", arguments: [acceleration.z])
        
        //        print("accX = " + accX + " || accY = " + accY + " || accZ = " + accZ)
        
        self.newAccelerationXData = accX
        self.newAccelerationYData = accY
        self.newAccelerationZData = accZ
        
        if accelerationArray.count < 45 {
            accelerationArray.append(newAccelerationXData)
            accelerationArray.append(newAccelerationYData)
            accelerationArray.append(newAccelerationZData)
        } else {
            makeStringToSaveCSV(sensorDataArray: accelerationArray, sensorType: "Acceleration")
            accelerationArray.removeAll()
        }
    }
    
    // 회전속도 측정값을 출력하는 메소드
    private func outputRotationData(_ rotation: CMRotationRate) {
        let rotX = String(format: "%.3f", arguments: [rotation.x])
        let rotY = String(format: "%.3f", arguments: [rotation.y])
        let rotZ = String(format: "%.3f", arguments: [rotation.z])
        
        //        print("rotX = " + rotX + " || rotY = " + rotY + " || rotZ = " + rotZ)
        
        self.newRotationXData = rotX
        self.newRotationYData = rotY
        self.newRotationZData = rotZ
        
        if rotationArray.count < 45 {
            rotationArray.append(newRotationXData)
            rotationArray.append(newRotationYData)
            rotationArray.append(newRotationZData)
        } else {
            makeStringToSaveCSV(sensorDataArray: rotationArray, sensorType: "Rotation")
            rotationArray.removeAll()
        }
    }
    
    // 고도, 기압 측정값을 출력하는 메소드
    private func outputAtitudeData(_ altitude: CMAltitudeData) {
        CheckSensorViewController.shared.sensorDataForCheck(altitude)
        
        let alt = altitude.relativeAltitude.stringValue
        let pre = String(format: "%.3f", Double(truncating: altitude.pressure) * 10)
        self.newAltitudeData = alt
        self.newPressureData = pre
        
        pressureArray.append(newPressureData)
        
        if pressureArray.count >= 1 {
            makeStringToSaveCSV(sensorDataArray: pressureArray, sensorType: "Pressure")
            pressureArray.removeAll()
        }
    }
    
    // CSV 파일에 입력될 String을 만들기 위해 실행되는 메소드
    private func makeStringToSaveCSV(sensorDataArray: [String], sensorType: String) {
        if sensorType == "Acceleration" {
            accelerationDataString += getUnixTime()
            
            for i in 0..<sensorDataArray.count {
                accelerationDataString += "," + sensorDataArray[i]
            }
            
            accelerationDataString += "\n"
        } else if sensorType == "Rotation" {
            rotationDataString += getUnixTime()
            
            for i in 0..<sensorDataArray.count {
                rotationDataString += "," + sensorDataArray[i]
            }
            
            rotationDataString += "\n"
        } else if sensorType == "Pressure" {
            pressureDataString += getUnixTime()
            
            pressureDataString += "," + sensorDataArray[0]
            
            pressureDataString += "\n"
        }
    }
    
    // 앱 재시작 시, 업로드되지 않은 파일의 인덱스를 확인하여 전부 업로드시키는 메소드
    private func checkWhenReStartSensorDatas() -> Int {
        let realm = try! Realm()
        let getRealmToCheck = realm.objects(SensorRealmManager.self)
        
        // Realm의 마지막 인덱스가 0이 아니면, 1 ~ 마지막 인덱스까지 업로드 인덱스가 0인 인덱스 필터링
        if getRealmToCheck.endIndex != 0 {
            for index in 0..<getLastIndexOfSensorRealm() + 1 {
                if index == 0 {
                    continue
                }
                let checkRealm = realm.object(ofType: SensorRealmManager.self, forPrimaryKey: index)
                
                if checkRealm?.lastUploadedmAccNumber == 0 || checkRealm?.lastUploadedmGyrNumber == 0 || checkRealm?.lastUploadedmPreNumber == 0 {
                    return index
                }
            }
        }
        
        // Check 시 남아 있는 파일 없음(이상 없음)
        return 0
    }
    
    // MARK: - @objc Method
    // Sensor CSV 파일을 만들고 업로드하는 메소드
    @objc private func makeSensorCSVFileAndUpload() {
        uploadTimeVariable = 600
        print("Start save and upload")
        
        let realm = try! Realm()
        let getRealm = realm.objects(SensorRealmManager.self)
        indexCount = getRealm.endIndex
        
        indexCount += 1
        
        let saveNewIndexInRealm = SensorRealmManager()
        saveNewIndexInRealm.lastSavedNumber = indexCount
        saveNewIndexInRealm.lastUploadedmAccNumber = 0
        saveNewIndexInRealm.lastUploadedmGyrNumber = 0
        saveNewIndexInRealm.lastUploadedmPreNumber = 0
        try! realm.write {
            realm.add(saveNewIndexInRealm)
        }
        
        CSVFileManager.shared.writeSensorCSV(sensorData: accelerationDataString, sensorType: "mAcc", index: indexCount)
        CSVFileManager.shared.writeSensorCSV(sensorData: rotationDataString, sensorType: "mGyr", index: indexCount)
        CSVFileManager.shared.writeSensorCSV(sensorData: pressureDataString, sensorType: "mPre", index: indexCount)
        
        accelerationDataString = ""
        rotationDataString = ""
        pressureDataString = ""
        
        CSVFileManager.shared.checkInternetAndStartUploadSensorData()
    }
    
    // 앱 재시작 후 잔여 파일을 모두 업로드하기 위한 메소드
    @objc private func reuploadFiles(completion: @escaping () -> Void) {
        if NetWorkManager.shared.isConnected == true {
            for index in checkWhenReStartSensorDatas()..<getLastIndexOfSensorRealm() + 1 {
                CSVFileManager.shared.readAndUploadSensorCSV(fileNumber: index)
            }
            
            if checkWhenReStartSensorDatas() == 0 {
                restartAndCheckTimer.invalidate()
            }
        }
        
        completion()
    }
    
    // 업로드 주기를 확인하기 위한 메소드
    @objc func uploadTimeLabelMethod() {
        if uploadTimeVariable > 0 {
            uploadTimeVariable -= 1
        }
    }
    
}
