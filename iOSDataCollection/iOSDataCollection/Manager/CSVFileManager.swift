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
    
    let containerNameArray: [String] = ["mAcc", "mGyr", "mPre"]
    
    // CSV 파일이 업로드되었는지 확인하는 Bool 값
    var csvFileUploaded: Bool = false
    
    // 파일을 불러올 인덱스 번호를 입력받을 변수
    var fileNumber: Int!
    
    // MARK: - Instanace member
    
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
                let csvData = csvFile.replacingOccurrences(of: "\n", with: "")
                uploadSensorDataToMobius(csvData: csvData, containerName: containerName)
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
    
    // Mobius 서버에 CSV 파일을 업로드하는 메소드
    func uploadSensorDataToMobius(csvData: String, containerName: String) {
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
//            print(String(data: data, encoding: .utf8)!)
            print("\(containerName) Data is served.")
            semaphore.signal()
        }

        task.resume()
        semaphore.wait()
    }
    
}
