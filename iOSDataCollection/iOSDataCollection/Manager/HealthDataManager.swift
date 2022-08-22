//
//  HealthDataManager.swift
//  iOSDataCollection
//
//  Created by ROLF J. on 2022/08/02.
//

import Foundation
import HealthKit
import RealmSwift

class HealthDataManager {
    
    static let shared = HealthDataManager()
    
    let healthStore = HKHealthStore()
    
    // MARK: - Instance member
    // Health 데이터들을 업로드하기 위한 타이머
    var uploadHealthDataTimer = Timer()
    
    // 앱 재시작 후의 잔여 파일을 감지하고 인터넷 연결을 지속적으로 체크하기 위한 타이머
    var restartAndCheckTimer = Timer()
    
    // 걸음 수 데이터를 HKSample 형식으로 받아들일 배열, 받아들인 배열 구조를 업로드할 구조로 재구성할(startTime, endTime, data) 배열, 업로드를 위한 문자열
    var stepDataArray: [HKSample] = []
    var stepStringDataArray: [String] = []
    var stepStringToUpload = ""
    
    // 활성 에너지 수 데이터를 HKSample 형식으로 받아들일 배열, 받아들인 배열 구조를 업로드할 구조로 재구성할(startTime, endTime, data) 배열, 업로드를 위한 문자열
    var energyDataArray: [HKSample] = []
    var energyStringDataArray: [String] = []
    var energyStringToUpload = ""
    
    // 걷고 뛴 거리 데이터를 HKSample 형식으로 받아들일 배열, 받아들인 배열 구조를 업로드할 구조로 재구성할(startTime, endTime, data) 배열, 업로드를 위한 문자열
    var distanceDataArray: [HKSample] = []
    var distanceStringDataArray: [String] = []
    var distanceStringToUpload = ""
    
    // 파일을 저장할 때 인덱싱을 하기 위한 변수
    var indexCount: Int = 0
    
    // Health 데이터의 컨테이너 이름 배열
    let healthContainerNameArray: [String] = ["steps", "calories", "distance"]
    
    // MARK: - Method
    // 앱 재시작 시, 업로드되지 않은 파일의 인덱스를 확인하여 전부 업로드시키는 메소드
    private func checkWhenReStartHealthDatas() -> Int {
        let realm = try! Realm()
        let getRealmToCheck = realm.objects(HealthRealmManager.self)
        
        // Realm의 마지막 인덱스가 0이 아니면, 1 ~ 마지막 인덱스까지 업로드 인덱스가 0인 인덱스 필터링
        if getRealmToCheck.endIndex != 0 {
            for index in 0..<getLastIndexOfHealthRealm() + 1 {
                if index == 0 {
                    continue
                }
                let checkRealm = realm.object(ofType: HealthRealmManager.self, forPrimaryKey: index)
                
                if checkRealm?.lastUploadedStepNumber == 0 || checkRealm?.lastUploadedEnergyNumber == 0 {
                    return index
                }
            }
        }
        
        // Check 시 남아 있는 파일 없음(이상 없음)
        return 0
    }
    
    // 건강 정보를 읽기 위해 사용자의 허가를 얻기 위한 메소드
    func requestHealthDataAuthorization() {
        if HKHealthStore.isHealthDataAvailable() {
            let read = Set([HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!, HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!, HKObjectType.quantityType(forIdentifier: .stepCount)!, HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!])
            let share = Set([HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!, HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!, HKObjectType.quantityType(forIdentifier: .stepCount)!, HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!])
            
            healthStore.requestAuthorization(toShare: share, read: read) { (success, error) in
                if error != nil {
                    print(error?.localizedDescription ?? "HealthKit Error")
                    self.requestHealthDataAuthorization()
                } else {
                    if success {
                        print("HealthKit 권한이 허가되었습니다.")
                    } else {
                        print("HealthKit 권한이 없습니다.")
                        self.requestHealthDataAuthorization()
                    }
                }
            }
        }
    }
    
    // 걸음 수를 얻는 메소드
    func getStepCountPerDay(end: Date) {
        print(end)
        
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return }
        let startDate = Calendar.current.startOfDay(for: end)
        print(startDate)
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: end, options: .strictStartDate)
        
        let query = HKSampleQuery(sampleType: stepType, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: nil) { (_, result, error) in
            let result = result
            
            for newResult in result! {
                self.stepDataArray.append(newResult)
            }
            
            for dataIndex in 0..<self.stepDataArray.count {
                
                let printResult = self.stepDataArray[dataIndex]
                
                let startCollectTime = Int(printResult.startDate.timeIntervalSince1970)
                let endCollectTime = Int(printResult.endDate.timeIntervalSince1970)
                let collectDevice = printResult.device?.model
                let printResultToQuantity: HKQuantitySample = printResult as! HKQuantitySample
                let collectedStepData = Int(printResultToQuantity.quantity.doubleValue(for: .count()))
                
                let newStepData = "\(startCollectTime),\(endCollectTime),\(collectDevice!),\(collectedStepData)"
                
                self.stepStringDataArray.append(newStepData)
            }
        }
        
        healthStore.execute(query)
    }
    
    // 사용한 활성에너지(cal)를 얻는 메소드
    func getActiveEnergyPerDay(end: Date) {
        guard let activeEnergyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else { return }
        let startTime = Calendar.current.startOfDay(for: end)
        let predicate = HKQuery.predicateForSamples(withStart: startTime, end: end, options: .strictStartDate)
        
        let query = HKSampleQuery(sampleType: activeEnergyType, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: nil) { (_, result, error) in
            let results = result
            
            for newResult in results! {
                self.energyDataArray.append(newResult)
            }
            
            for dataIndex in 0..<self.energyDataArray.count {
                
                let printResult = self.energyDataArray[dataIndex]
                
                let startCollectTime = Int(printResult.startDate.timeIntervalSince1970)
                let endCollectTime = Int(printResult.endDate.timeIntervalSince1970)
                let collectDevice = printResult.device?.model
                let printResultToQuantity: HKQuantitySample = printResult as! HKQuantitySample
                let collectedEnergyData = Int(printResultToQuantity.quantity.doubleValue(for: .smallCalorie()) * 1000)
                
                let newEnergyData = "\(startCollectTime),\(endCollectTime),\(collectDevice!),\(collectedEnergyData)"
                
                self.energyStringDataArray.append(newEnergyData)
            }
        }
        
        healthStore.execute(query)
    }
    
    // 걷고 뛴 거리(meter)를 얻는 메소드
    func getDistanceWalkAndRunPerDay(end: Date) {
        guard let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) else { return }
        let startTime = Calendar.current.startOfDay(for: end)
        let predicate = HKQuery.predicateForSamples(withStart: startTime, end: end, options: .strictStartDate)
        
        let query = HKSampleQuery(sampleType: distanceType, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: nil) { (_, result, error) in
            let results = result
            
            for newResult in results! {
                self.distanceDataArray.append(newResult)
            }
            
            for dataIndex in 0..<self.distanceDataArray.count {
                
                let printResult = self.distanceDataArray[dataIndex]
                
                let startCollectTime = Int(printResult.startDate.timeIntervalSince1970)
                let endCollectTime = Int(printResult.endDate.timeIntervalSince1970)
                let collectDevice = printResult.device?.model
                let printResultToQuantity: HKQuantitySample = printResult as! HKQuantitySample
                let collectedDistanceData = Int(printResultToQuantity.quantity.doubleValue(for: .meter()))
                
                let newDistanceData = "\(startCollectTime),\(endCollectTime),\(collectDevice!),\(collectedDistanceData)"
                
                self.distanceStringDataArray.append(newDistanceData)
            }
        }
        
        healthStore.execute(query)
    }
    
    // 받아온 건강 정보들을 CSV 파일(문자열)로 만드는 메소드
    func makeHealthDataString(dataType: String) {
        if dataType == "steps" {
            stepStringToUpload += stepStringDataArray[0]
            
            if stepStringDataArray.count > 1 {
                for dataIndex in 1..<self.stepStringDataArray.count {
                    self.stepStringToUpload += "," + self.stepStringDataArray[dataIndex]
                }
            }
        } else if dataType == "calories" {
            energyStringToUpload += energyStringDataArray[0]
            
            if energyStringDataArray.count > 1 {
                for dataIndex in 1..<self.energyStringDataArray.count {
                    energyStringToUpload += "," + energyStringDataArray[dataIndex]
                }
            }
        } else if dataType == "distance" {
            distanceStringToUpload += distanceStringDataArray[0]
            
            if distanceStringDataArray.count > 1 {
                for dataIndex in 1..<self.distanceStringDataArray.count {
                    distanceStringToUpload += "," + distanceStringDataArray[dataIndex]
                }
            }
        }
    }
    
    // 건강 정보를 받아오는 루프를 생성하는 메소드
    func getHealthDataLoop() {
        let calendar = Calendar.current
        
        let startTime = Date()
        let getDataTime = calendar.date(bySettingHour: 00, minute: 01, second: 00, of: startTime)!
        
        var getHealthDataTimer = Timer()
        
        getHealthDataTimer = Timer.init(fireAt: getDataTime, interval: 86400, target: self, selector: #selector(makeHealthCSVFileAndUpload), userInfo: nil, repeats: true)
        
        print("Collecting health data loop started")
        print("------------------------------------------------------------")
        RunLoop.main.add(getHealthDataTimer, forMode: .common)
    }
    
    // Health Realm의 마지막 인덱스를 읽어오는 메소드
    func getLastIndexOfHealthRealm() -> Int {
        let realm = try! Realm()
        let getRealm = realm.objects(HealthRealmManager.self)
        let getLastIndex = getRealm.endIndex
        
        return getLastIndex
    }
    
    // 앱 재시작 시(checkWhenReStart), 업로드해야 할 건강 데이터 파일이 남아 있다면 인터넷 연결을 체크하고 남은 파일을 한번에 업로드함
    func checkAndReUploadHealthFiles() {
        if checkWhenReStartHealthDatas() != 0 {
            restartAndCheckTimer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(reuploadFiles), userInfo: nil, repeats: true)
        }
    }
    
    // 앱 재시작 시 건강 데이터 파일이 업로드되었는지 확인
    func checkHealthDataUploaded(property: String, fileIndex: Int) -> Bool {
        let realm = try! Realm()
        let getRealm = realm.objects(HealthRealmManager.self)
        
        if property == "steps" {
            if getRealm[fileIndex].lastUploadedStepNumber == 0 {
                return false
            }
        } else if property == "calories" {
            if getRealm[fileIndex].lastUploadedEnergyNumber == 0 {
                return false
            }
        } else if property == "distance" {
            if getRealm[fileIndex].lastUploadedDistanceNumber == 0 {
                return false
            }
        }
        
        return true
    }
    
    // 앱 재시작 시, 건강 데이터 파일이 CSV 파일로 저장되어 있는지 확인하기 위한 메소드
    func checkHealthCSVExist(fileName: String, fileIndex: Int) -> Bool {
        let fileManager: FileManager = FileManager.default
        
        let folderName = "saveHealthCSVFolder"
        let csvFileName = "\(fileName)_\(fileIndex).csv"
        
        let documentUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let diretoryUrl = documentUrl.appendingPathComponent(folderName)
        let fileUrl = diretoryUrl.appendingPathComponent(csvFileName)
        
        do {
            let dataFromPath: Data = try Data(contentsOf: fileUrl)
            let csvFile: String = String(data: dataFromPath, encoding: .utf8) ?? "문서 없음"
            if csvFile == "문서 없음" {
                return false
            }
        } catch let error {
            print(error.localizedDescription)
        }
        
        return true
    }
    
    // MARK: - @objc Method
    // 앱 재시작 후 잔여 파일을 모두 업로드하기 위한 메소드
    @objc private func reuploadFiles(completion: @escaping () -> Void) {
        if NetWorkManager.shared.isConnected == true {
            for index in checkWhenReStartHealthDatas()..<getLastIndexOfHealthRealm() + 1 {
                for containerName in healthContainerNameArray {
                    if checkHealthDataUploaded(property: containerName, fileIndex: index) == false {
                        if checkHealthCSVExist(fileName: containerName, fileIndex: index) == false {
                            let realm = try! Realm()
                            let getRealm = realm.objects(HealthRealmManager.self)
                            
                            let notUploadedUnixTimeString = getRealm[index].saveUnixTime
                            let notUploadedUnixTime = Double(notUploadedUnixTimeString)
                            let notUploadedDate = Date(timeIntervalSince1970: notUploadedUnixTime!)
                            
                            if containerName == "steps" {
                                getStepCountPerDay(end: notUploadedDate)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                                    self.makeHealthDataString(dataType: "steps")
                                    CSVFileManager.shared.writeHealthCSV(sensorData: self.stepStringToUpload, dataType: "steps", index: index)
                                    self.stepDataArray.removeAll()
                                    self.stepStringDataArray.removeAll()
                                    self.stepStringToUpload = ""
                                }
                            } else if containerName == "calories" {
                                getActiveEnergyPerDay(end: notUploadedDate)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                                    self.makeHealthDataString(dataType: "calories")
                                    CSVFileManager.shared.writeHealthCSV(sensorData: self.energyStringToUpload, dataType: "calories", index: index)
                                    self.energyDataArray.removeAll()
                                    self.energyStringDataArray.removeAll()
                                    self.energyStringToUpload = ""
                                }
                            } else if containerName == "distance" {
                                getDistanceWalkAndRunPerDay(end: notUploadedDate)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                                    self.makeHealthDataString(dataType: "distance")
                                    CSVFileManager.shared.writeHealthCSV(sensorData: self.distanceStringToUpload, dataType: "distance", index: index)
                                    self.distanceDataArray.removeAll()
                                    self.distanceStringDataArray.removeAll()
                                    self.distanceStringToUpload = ""
                                }
                            }
                        }
                    }
                }
                
                CSVFileManager.shared.readAndUploadHealthCSV(fileNumber: index)
                if checkWhenReStartHealthDatas() == 0 {
                    restartAndCheckTimer.invalidate()
                }
            }
        }
        
        completion()
    }
    
    // Health CSV 파일을 만들고 업로드하는 메소드
    @objc func makeHealthCSVFileAndUpload() {
        print("Start save and upload health data")
        
        let now = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: now)
        let end = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: yesterday ?? Date())
        let todayEndUnixTime = String(end!.timeIntervalSince1970)
        
        let realm = try! Realm()
        let getRealm = realm.objects(HealthRealmManager.self)
        indexCount = getRealm.endIndex
        
        indexCount += 1
        
        let saveNewIndexInRealm = HealthRealmManager()
        saveNewIndexInRealm.lastSavedNumber = indexCount
        saveNewIndexInRealm.saveUnixTime = todayEndUnixTime
        saveNewIndexInRealm.lastUploadedStepNumber = 0
        saveNewIndexInRealm.lastUploadedEnergyNumber = 0
        saveNewIndexInRealm.lastUploadedDistanceNumber = 0
        try! realm.write {
            realm.add(saveNewIndexInRealm)
        }
        
        getStepCountPerDay(end: end!)
        getActiveEnergyPerDay(end: end!)
        getDistanceWalkAndRunPerDay(end: end!)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            for array in self.healthContainerNameArray {
                self.makeHealthDataString(dataType: array)
            }
            
            CSVFileManager.shared.writeHealthCSV(sensorData: self.stepStringToUpload, dataType: "steps", index: self.indexCount)
            CSVFileManager.shared.writeHealthCSV(sensorData: self.energyStringToUpload, dataType: "calories", index: self.indexCount)
            CSVFileManager.shared.writeHealthCSV(sensorData: self.distanceStringToUpload, dataType: "distance", index: self.indexCount)
            
            self.stepDataArray.removeAll()
            self.energyDataArray.removeAll()
            self.distanceDataArray.removeAll()
            self.stepStringDataArray.removeAll()
            self.energyStringDataArray.removeAll()
            self.distanceStringDataArray.removeAll()
            self.stepStringToUpload = ""
            self.energyStringToUpload = ""
            self.distanceStringToUpload = ""
            
            CSVFileManager.shared.checkInternetAndStartUploadHealthData()
        }
    }
    
}
