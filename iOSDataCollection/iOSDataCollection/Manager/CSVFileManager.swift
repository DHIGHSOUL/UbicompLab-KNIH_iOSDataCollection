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
    
    let containerNameArray: [String] = ["mAcc", "mGyr", "mPre"]
    
    // CSV 파일이 업로드되었는지 확인하는 Bool 값
    var csvFileUploaded: Bool = false
    
    // 파일을 불러올 인덱스 번호를 입력받을 변수
    var fileNumber: Int = 0
    
    // 인터넷 연결이 없을 때, 반복적으로 인터넷 연결을 확인하고, 연결 시 바로 모든 데이터를 업로드할 타이머
    var uploadFailTimer = Timer()
    // 인터넷 연결이 없을 때, 업로드되지 못한 파일의 인덱스를 가지고 있을 변수
    var uploadFailNumber: Int = 0
    // 마지막으로 업로드된 인덱스 값을 읽어올 변수
    var lastSavedNumber: Int = 0
    // 업로드에 재실패했는지 확인하기 위한 변수 -> 재실패했다면 마지막 실패 지점을 업데이트하지 않게 하기 위함
    var checkFailAgain: Int = 0

    // MARK: - Method
    // CSV 폴더를 생성하는 메소드
    func createCSVFolder() {
        let fileManager: FileManager = FileManager.default
        
        print("CSV 폴더 생성됨")
        let folderName = "saveCSVFolder"
        
        let documentUrl: URL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let directoryUrl: URL = documentUrl.appendingPathComponent(folderName)
        
        do {
            try fileManager.createDirectory(atPath: directoryUrl.path, withIntermediateDirectories: true, attributes: nil)
        }
        catch let error as NSError {
            print("폴더 생성 에러: \(error)")
        }
    }
    
    // 센서 데이터를 CSV 파일에 저장하는 메소드
    func writeCSV(sensorData: String, sensorType: String, index: Int) {
        let fileManager: FileManager = FileManager.default
        
        print("\(sensorType)_\(index).csv 파일 생성됨")
        let folderName = "saveCSVFolder"
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
    
    // CSV 파일을 업로드하기 위해 인터넷 연결을 체크하고, 연결이 되어 있다면 업로드를 시작하는 메소드
    func checkInternetAndStartUpload() {
        if NetWorkManager.shared.isConnected == true {
            let realm = try! Realm()
            let getLastIndex = realm.objects(RealmManager.self)
            
            fileNumber = getLastIndex.endIndex
            
            readAndUploadCSV(fileNumber: fileNumber)
        } else {
            if checkFailAgain == 0 {
                uploadFailNumber = fileNumber
                uploadFailTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(reuploadIfInternetConnected), userInfo: nil, repeats: true)
                checkFailAgain = 1
            }
        }
    }
    
    // CSV 파일을 읽어온 후 Mobius 서버에 업로드하는 메소드
    func readAndUploadCSV(fileNumber: Int) {
        for containerName in containerNameArray {
            let fileManager: FileManager = FileManager.default
            
            let folderName = "saveCSVFolder"
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
                let csvData = csvFile.replacingOccurrences(of: "\n", with: "")
                uploadSensorDataToMobius(csvData: csvData, containerName: containerName, fileNumber: fileNumber)
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
    
    // Mobius 서버에 CSV 파일을 업로드하는 메소드
    func uploadSensorDataToMobius(csvData: String, containerName: String, fileNumber: Int) {
        let semaphore = DispatchSemaphore (value: 0)
        
        let parameters = "{\n    \"m2m:cin\": {\n        \"con\": \"\(csvData)\"\n    }\n}"
        let postData = parameters.data(using: .utf8)
        
        var request = URLRequest(url: URL(string: "http://114.71.220.59:7579/Mobius/S899/mobile/\(containerName)")!,timeoutInterval: Double.infinity)
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
                self.updateLastUploadedmAccNumber()
            } else if containerName == "mGyr" {
                self.updateLastUploadedmGyrNumber()
            } else if containerName == "mPre" {
                self.updateLastUploadedmPreNumber()
            }
            
            self.removeCSV(containerName: containerName, index: fileNumber)
            
            print("\(containerName) Data is served.")
            semaphore.signal()
        }
        
        task.resume()
        semaphore.wait()
    }
    
    // 각각 mAcc, mGyr, mPre 파잃이 업로드 성공되었을 때 Realm 내의 프로퍼티를 +1 시킴(1은 '이미 업로드됨', 0은 '업로드 되지 않음)
    func updateLastUploadedmAccNumber() {
        let realm = try! Realm()
        
        guard let updateRealm = realm.object(ofType: RealmManager.self, forPrimaryKey: self.fileNumber) else {
            print("File_\(String(describing: self.fileNumber)) not found")
            return
        }
        
        try! realm.write {
            updateRealm.lastUploadedmAccNumber = 1
        }
    }
    func updateLastUploadedmGyrNumber() {
        let realm = try! Realm()
        
        guard let updateRealm = realm.object(ofType: RealmManager.self, forPrimaryKey: self.fileNumber) else {
            print("File_\(String(describing: self.fileNumber)) not found")
            return
        }
        
        try! realm.write {
            updateRealm.lastUploadedmGyrNumber = 1
        }
    }
    func updateLastUploadedmPreNumber() {
        let realm = try! Realm()
        
        guard let updateRealm = realm.object(ofType: RealmManager.self, forPrimaryKey: self.fileNumber) else {
            print("File_\(String(describing: self.fileNumber)) not found")
            return
        }
        
        try! realm.write {
            updateRealm.lastUploadedmPreNumber = 1
        }
    }
    
    // CSV 파일을 삭제하는 메소드
    func removeCSV(containerName: String, index: Int) {
        let fileManager: FileManager = FileManager.default
        
        let folderName = "saveCSVFolder"
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
    
    // 10초마다 인터넷 연결을 확인하여, 인터넷에 연결되면 업로드를 실패한 지점부터 마지막 저장된 인덱스의 파일까지 모두 업로드하는 메소드
    @objc func reuploadIfInternetConnected() {
        if NetWorkManager.shared.isConnected == true {
            let realm = try! Realm()
            let getLastIndex = realm.objects(RealmManager.self)
            
            lastSavedNumber = getLastIndex.endIndex
            
            for number in uploadFailNumber..<lastSavedNumber + 1 {
                readAndUploadCSV(fileNumber: number)
            }
            
            checkFailAgain = 0
            uploadFailTimer.invalidate()
        }
    }
    
}
