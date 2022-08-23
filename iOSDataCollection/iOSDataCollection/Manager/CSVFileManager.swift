//
//  CSVFileManager.swift
//  iOSDataCollection
//
//  Created by ROLF J. on 2022/07/26.
//

import Foundation
import RealmSwift

class CSVFileManager {
    
    static let shared = CSVFileManager()
    
    // MARK: - Instanace member
    // 센서 데이터의 컨테이너 이름 배열
    let sensorContainerNameArray: [String] = ["mAcc", "mGyr", "mPre"]
    
    // Health 데이터의 컨테이너 이름 배열
    let healthContainerNameArray: [String] = ["steps", "calories", "distance", "sleep"]
    
    // CSV 파일이 업로드되었는지 확인하는 Bool 값
    var csvFileUploaded: Bool = false
    
    // 파일을 불러올 인덱스 번호를 입력받을 변수
    var sensorFileNumber: Int = 0
    
    // Health Data 파일을 불러올 인덱스 번호를 입력받을 변수
    var healthFileNumber: Int = 0
    
    // 인터넷 연결이 없을 때, 반복적으로 인터넷 연결을 확인하고, 연결 시 바로 모든 센서 데이터를 업로드할 타이머
    var uploadFailSensorTimer = Timer()
    // 인터넷 연결이 없을 때, 업로드되지 못한 Sensor CSV파일의 인덱스를 가지고 있을 변수
    var uploadFailSensorNumber: Int = 0
    // 인터넷 연결이 없을 때, 반복적으로 인터넷 연결을 확인하고, 연결 시 바로 모든 건강 데이터를 업로드할 타이머
    var uploadFailHealthTimer = Timer()
    // 인터넷 연결이 없을 때, 업로드되지 못한 Health CSV파일의 인덱스를 가지고 있을 변수
    var uploadFailHealthNumber: Int = 0
    // 마지막으로 업로드된 센서 데이터 인덱스 값을 읽어올 변수
    var lastSavedSensorNumber: Int = 0
    // 센서 데이터 업로드에 재실패했는지 확인하기 위한 변수 -> 재실패했다면 마지막 실패 지점을 업데이트하지 않게 하기 위함
    var checkFailAgainUploadSensorData: Int = 0
    // 마지막으로 업로드된 건강 데이터 인덱스 값을 읽어올 변수
    var lastSavedHealthNumber: Int = 0
    // 건강 데이터 업로드에 재실패했는지 확인하기 위한 변수 -> 재실패했다면 마지막 실패 지점을 업데이트하지 않게 하기 위함
    var checkFailAgainUploadHealthData: Int = 0
    
    // MARK: - Method
    // 센서 데이터를 저장할 CSV 폴더를 생성하는 메소드
    func createSensorCSVFolder() {
        let fileManager: FileManager = FileManager.default
        
        print("Sensor용 CSV 폴더 생성됨")
        let folderName = "saveSensorCSVFolder"
        
        let documentUrl: URL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        print(documentUrl)
        let directoryUrl: URL = documentUrl.appendingPathComponent(folderName)
        
        do {
            try fileManager.createDirectory(atPath: directoryUrl.path, withIntermediateDirectories: true, attributes: nil)
        }
        catch let error as NSError {
            print("폴더 생성 에러: \(error)")
        }
    }
    
    // 건강 데이터를 저장할 CSV 폴더를 생성하는 메소드
    func createHealthCSVFolder() {
        let fileManager: FileManager = FileManager.default
        
        print("Health Data용 CSV 폴더 생성됨")
        let folderName = "saveHealthCSVFolder"
        
        let documentUrl: URL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        print(documentUrl)
        let directoryUrl: URL = documentUrl.appendingPathComponent(folderName)
        
        do {
            try fileManager.createDirectory(atPath: directoryUrl.path, withIntermediateDirectories: true, attributes: nil)
        }
        catch let error as NSError {
            print("폴더 생성 에러: \(error)")
        }
    }
    
    // 센서 데이터를 CSV 파일에 저장하는 메소드
    func writeSensorCSV(sensorData: String, sensorType: String, index: Int) {
        let fileManager: FileManager = FileManager.default
        
        print("\(sensorType)_\(index).csv 파일 생성됨")
        let folderName = "saveSensorCSVFolder"
        let csvFileName = "\(sensorType)_\(index).csv"
        
        let documentUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let directoryUrl = documentUrl.appendingPathComponent(folderName)
        
        let fileUrl: URL = directoryUrl.appendingPathComponent(csvFileName)
        let fileData = sensorData.data(using: .utf8)
        
        do {
            try fileData?.write(to: fileUrl)
            print("Writing CSV to: \(fileUrl.path)")
        }
        catch let error as NSError {
            print("CSV파일 생성 에러: \(error)")
        }
    }
    
    // 건강 데이터를 CSV 파일에 저장하는 메소드
    func writeHealthCSV(sensorData: String, dataType: String, index: Int) {
        let fileManager: FileManager = FileManager.default
        
        print("\(dataType)_\(index).csv 파일 생성됨")
        let folderName = "saveHealthCSVFolder"
        let csvFileName = "\(dataType)_\(index).csv"
        
        let documentUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let directoryUrl = documentUrl.appendingPathComponent(folderName)
        
        let fileUrl: URL = directoryUrl.appendingPathComponent(csvFileName)
        let fileData = sensorData.data(using: .utf8)
        
        do {
            try fileData?.write(to: fileUrl)
            print("Writing CSV to: \(fileUrl.path)")
        }
        catch let error as NSError {
            print("CSV파일 생성 에러: \(error)")
        }
    }
    
    // Sensor CSV 파일을 업로드하기 위해 인터넷 연결을 체크하고, 연결이 되어 있다면 센서 데이터 업로드를 시작하는 메소드
    func checkInternetAndStartUploadSensorData() {
        if NetWorkManager.shared.isConnected == true {
            sensorFileNumber = DataCollectionManager.shared.getLastIndexOfSensorRealm()
            
            readAndUploadSensorCSV(fileNumber: sensorFileNumber)
        } else {
            if checkFailAgainUploadSensorData == 0 {
                uploadFailSensorNumber = sensorFileNumber
                uploadFailSensorTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(reuploadSensorDataIfInternetConnected), userInfo: nil, repeats: true)
                checkFailAgainUploadSensorData = 1
            }
        }
    }
    
    // Health CSV 파일을 업로드하기 위해 인터넷 연결을 체크하고, 연결이 되어 있다면 센서 데이터 업로드를 시작하는 메소드
    func checkInternetAndStartUploadHealthData() {
        if NetWorkManager.shared.isConnected == true {
            healthFileNumber = HealthDataManager.shared.getLastIndexOfHealthRealm()
            
            readAndUploadHealthCSV(fileNumber: healthFileNumber)
        } else {
            if checkFailAgainUploadHealthData == 0 {
                uploadFailHealthNumber = healthFileNumber
                uploadFailHealthTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(reuploadHealthDataIfInternetConnected), userInfo: nil, repeats: true)
                checkFailAgainUploadHealthData = 1
            }
        }
    }
    
    // Sensor CSV 파일을 읽어온 후 Mobius 서버에 업로드하는 메소드
    func readAndUploadSensorCSV(fileNumber: Int) {
        for containerName in sensorContainerNameArray {
            let fileManager: FileManager = FileManager.default
            
            let folderName = "saveSensorCSVFolder"
            let csvFileName = "\(containerName)_\(fileNumber).csv"
            
            let documentUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            let diretoryUrl = documentUrl.appendingPathComponent(folderName)
            let fileUrl = diretoryUrl.appendingPathComponent(csvFileName)
            
            do {
                let dataFromPath: Data = try Data(contentsOf: fileUrl)
                let csvFile: String = String(data: dataFromPath, encoding: .utf8) ?? "문서 없음"
                if csvFile == "문서 없음" {
                    return
                }
                let csvData = csvFile.replacingOccurrences(of: "\n", with: ",")
                uploadCSVDataToMobius(csvData: csvData, containerName: containerName, fileNumber: fileNumber)
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
    
    // Health CSV 파일을 읽어온 후 Mobius 서버에 업로드하는 메소드
    func readAndUploadHealthCSV(fileNumber: Int) {
        for containerName in healthContainerNameArray {
            let fileManager: FileManager = FileManager.default
            
            let folderName = "saveHealthCSVFolder"
            let csvFileName = "\(containerName)_\(fileNumber).csv"
            
            let documentUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            let diretoryUrl = documentUrl.appendingPathComponent(folderName)
            let fileUrl = diretoryUrl.appendingPathComponent(csvFileName)
            
            do {
                let dataFromPath: Data = try Data(contentsOf: fileUrl)
                let csvFile: String = String(data: dataFromPath, encoding: .utf8) ?? "문서 없음"
                if csvFile == "문서 없음" {
                    return
                }
                let csvData = csvFile
                uploadCSVDataToMobius(csvData: csvData, containerName: containerName, fileNumber: fileNumber)
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
    
    // Mobius 서버에 CSV 파일을 업로드하는 메소드
    private func uploadCSVDataToMobius(csvData: String, containerName: String, fileNumber: Int) {
        let semaphore = DispatchSemaphore (value: 0)
        
        let parameters = "{\n    \"m2m:cin\": {\n        \"con\": \"\(csvData)\"\n    }\n}"
        let postData = parameters.data(using: .utf8)
        
        let userID = UserDefaults.standard.string(forKey: "ID")!
        var mainContainerName: String = ""
        
        if containerName == "mAcc" || containerName == "mGyr" || containerName == "mPre" {
            mainContainerName = "mobile"
        } else if containerName == "steps" || containerName == "calories" || containerName == "distance" || containerName == "sleep" {
            mainContainerName = "health"
        }
        
        var request = URLRequest(url: URL(string: "http://114.71.220.59:7579/Mobius/\(String(describing: userID))/\(mainContainerName)/\(containerName)")!,timeoutInterval: Double.infinity)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("12345", forHTTPHeaderField: "X-M2M-RI")
        request.addValue("SIWLTfduOpL", forHTTPHeaderField: "X-M2M-Origin")
        request.addValue("application/vnd.onem2m-res+json; ty=4", forHTTPHeaderField: "Content-Type")
        
        request.httpMethod = "POST"
        request.httpBody = postData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard data != nil else {
                print(String(describing: error))
                semaphore.signal()
                return
            }
            
            // POST 성공 여부 체크, POST 실패 시 return
            let successsRange = 200..<300
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, successsRange.contains(statusCode)
            else {
                print("")
                print("====================================")
                print("[requestPOST : http post 요청 에러]")
                print("error : ", (response as? HTTPURLResponse)?.statusCode ?? 0)
                print("msg : ", (response as? HTTPURLResponse)?.description ?? "")
                print("====================================")
                print("")
                return
            }
            
            if containerName == "mAcc" {
                self.updateLastUploadedmAccNumber(fileNumber: fileNumber)
            } else if containerName == "mGyr" {
                self.updateLastUploadedmGyrNumber(fileNumber: fileNumber)
            } else if containerName == "mPre" {
                self.updateLastUploadedmPreNumber(fileNumber: fileNumber)
            } else if containerName == "steps" {
                self.updateLastUploadedStepsNumber(fileNumber: fileNumber)
            } else if containerName == "calories" {
                self.updateLastUploadedCaloriesNumber(fileNumber: fileNumber)
            } else if containerName == "distance" {
                self.updateLastUploadedDistancenumber(fileNumber: fileNumber)
            } else if containerName == "sleep" {
                self.updateLastUploadedSleepNumber(fileNumber: fileNumber)
            }
            
            self.removeCSV(containerName: containerName, index: fileNumber)
            
            print("\(containerName) Data is served.")
            semaphore.signal()
        }
        
        task.resume()
        semaphore.wait()
    }
    
    // 각각 mAcc, mGyr, mPre, steps, calories 파일이 업로드 성공되었을 때 Realm 내의 프로퍼티를 +1 시킴(1은 '이미 업로드됨', 0은 '업로드 되지 않음)
    private func updateLastUploadedmAccNumber(fileNumber: Int) {
        let realm = try! Realm()
        
        guard let updateRealm = realm.object(ofType: SensorRealmManager.self, forPrimaryKey: fileNumber) else {
            print("File_\(String(describing: self.sensorFileNumber)) not found")
            return
        }
        
        try! realm.write {
            updateRealm.lastUploadedmAccNumber = 1
        }
    }
    
    private func updateLastUploadedmGyrNumber(fileNumber: Int) {
        let realm = try! Realm()
        
        guard let updateRealm = realm.object(ofType: SensorRealmManager.self, forPrimaryKey: fileNumber) else {
            print("File_\(String(describing: self.sensorFileNumber)) not found")
            return
        }
        
        try! realm.write {
            updateRealm.lastUploadedmGyrNumber = 1
        }
    }
    
    private func updateLastUploadedmPreNumber(fileNumber: Int) {
        let realm = try! Realm()
        
        guard let updateRealm = realm.object(ofType: SensorRealmManager.self, forPrimaryKey: fileNumber) else {
            print("File_\(String(describing: self.sensorFileNumber)) not found")
            return
        }
        
        try! realm.write {
            updateRealm.lastUploadedmPreNumber = 1
        }
    }
    
    private func updateLastUploadedStepsNumber(fileNumber: Int) {
        let realm = try! Realm()
        
        guard let updateRealm = realm.object(ofType: HealthRealmManager.self, forPrimaryKey: fileNumber) else {
            print("File_\(String(describing: self.healthFileNumber)) not found")
            return
        }
        
        try! realm.write {
            updateRealm.lastUploadedStepNumber = 1
        }
    }
    
    private func updateLastUploadedCaloriesNumber(fileNumber: Int) {
        let realm = try! Realm()
        
        guard let updateRealm = realm.object(ofType: HealthRealmManager.self, forPrimaryKey: fileNumber) else {
            print("File_\(String(describing: self.healthFileNumber)) not found")
            return
        }
        
        try! realm.write {
            updateRealm.lastUploadedEnergyNumber = 1
        }
    }
    
    private func updateLastUploadedDistancenumber(fileNumber: Int) {
        let realm = try! Realm()
        
        guard let updateRealm = realm.object(ofType: HealthRealmManager.self, forPrimaryKey: fileNumber) else {
            print("File_\(String(describing: self.healthFileNumber)) not found")
            return
        }
        
        try! realm.write {
            updateRealm.lastUploadedDistanceNumber = 1
        }
    }
    
    private func updateLastUploadedSleepNumber(fileNumber: Int) {
        let realm = try! Realm()
        
        guard let updateRealm = realm.object(ofType: HealthRealmManager.self, forPrimaryKey: fileNumber) else {
            print("File_\(String(describing: self.healthFileNumber)) not founc")
            return
        }
        
        try! realm.write {
            updateRealm.lastUploadedSleepNumber = 1
        }
    }
    
    // CSV 파일을 삭제하는 메소드
    private func removeCSV(containerName: String, index: Int) {
        let fileManager: FileManager = FileManager.default
        
        var folderName = ""
        
        if containerName == "mAcc" || containerName == "mGyr" || containerName == "mPre" {
            folderName = "saveSensorCSVFolder"
        } else if containerName == "steps" || containerName == "calories" || containerName == "distance" || containerName == "sleep" {
            folderName = "saveHealthCSVFolder"
        }
        
        let csvFileName = "\(containerName)_\(index).csv"
        
        let documentUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let diretoryUrl = documentUrl.appendingPathComponent(folderName)
        let fileUrl = diretoryUrl.appendingPathComponent(csvFileName)
        
        do {
            try fileManager.removeItem(at: fileUrl)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    // MARK: - @objc Method
    // 특정 시간마다 인터넷 연결을 확인하여, 인터넷에 연결되면 센서 데이터 업로드를 실패한 지점부터 마지막 저장된 인덱스의 파일까지 모두 업로드하는 메소드
    @objc func reuploadSensorDataIfInternetConnected() {
        if NetWorkManager.shared.isConnected == true {
            lastSavedSensorNumber = DataCollectionManager.shared.getLastIndexOfSensorRealm()
            
            for number in uploadFailSensorNumber..<lastSavedSensorNumber + 1 {
                readAndUploadSensorCSV(fileNumber: number)
            }
            
            checkFailAgainUploadSensorData = 0
            uploadFailSensorTimer.invalidate()
        }
    }
    
    // 특정 시간마다 인터넷 연결을 확인하여, 인터넷에 연결되면 건강 데이터 업로드를 실패한 지점부터 마지막 저장된 인덱스의 파일까지 모두 업로드하는 메소드
    @objc func reuploadHealthDataIfInternetConnected() {
        if NetWorkManager.shared.isConnected == true {
            lastSavedHealthNumber = HealthDataManager.shared.getLastIndexOfHealthRealm()
            
            for number in uploadFailHealthNumber..<lastSavedHealthNumber + 1 {
                readAndUploadHealthCSV(fileNumber: number)
            }
            
            checkFailAgainUploadHealthData = 0
            uploadFailHealthTimer.invalidate()
        }
    }
    
}
