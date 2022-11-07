//
//  HealthDataManager.swift
//  iOSDataCollection
//
//  Created by ROLF J. on 2022/08/02.
//

import Foundation
import HealthKit
import RealmSwift
import Realm

class HealthDataManager {
    
    static let shared = HealthDataManager()
    
    let healthStore = HKHealthStore()
    
    // MARK: - Instance member
    // Health 데이터들을 업로드하기 위한 타이머
    var uploadHealthDataTimer = Timer()
    
    // 건강 정보를 받아올 루프를 생성하는 타이머
    var getHealthDataTimer = Timer()
    
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
    
    // 수면 데이터를 HKSample 형식으로 받아들일 배열, 받아들인 배열 구조를 업로드할 구조로 재구성할(startTime, endTime, data) 배열, 업로드를 위한 문자열
    var sleepDataArray: [HKCategorySample] = []
    var sleepStringDataArray: [String] = []
    var sleepStringToUpload = ""
    
    // 심박수 데이터를 HKSample 형식으로 받아들일 배열, 받아들인 배열 구조를 업로드할 구조로 재구성할(startTime, endTime, data) 배열, 업로드를 위한 문자열
    var heartRateDataArray: [HKSample] = []
    var heartRateStringDataArray: [String] = []
    var heartRateStringToUpload = ""
    
    // 파일을 저장할 때 인덱싱을 하기 위한 변수
    var indexCount: Int = 0
    
    // Health 데이터의 컨테이너 이름 배열
    let healthContainerNameArray: [String] = ["steps", "calories", "distance", "sleep", "HR"]
    
    // 현재 휴대폰의 잠금 상태를 파악할 변수
    var isPhoneLock = Bool()
    // 휴대폰이 잠겨 있다면 반복적으로 휴대폰 잠금 상태를 파악하는 타이머
    var phoneLockTimer = Timer()
    
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
                
                if checkRealm?.lastUploadedStepNumber == 0 || checkRealm?.lastUploadedEnergyNumber == 0 || checkRealm?.lastUploadedEnergyNumber == 0 || checkRealm?.lastUploadedDistanceNumber == 0 || checkRealm?.lastUploadedHeartRateNumber == 0 {
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
            let read = Set([HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!, HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!, HKObjectType.quantityType(forIdentifier: .stepCount)!, HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!, HKQuantityType.quantityType(forIdentifier: .heartRate)!])
            let share = Set([HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!, HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!, HKObjectType.quantityType(forIdentifier: .stepCount)!, HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!, HKQuantityType.quantityType(forIdentifier: .heartRate)!])
            
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
        let startTime = Calendar.current.startOfDay(for: end)
        print(startTime)
        
        let predicate = HKQuery.predicateForSamples(withStart: startTime, end: end, options: .strictStartDate)
        
        let query = HKSampleQuery(sampleType: stepType, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: nil) { (_, result, error) in
            if let error = error {
                print("Step Query Error, Set Error String : \(error.localizedDescription)")
                let errorStepString = "\(Int(startTime.timeIntervalSince1970)),\(Int(end.timeIntervalSince1970)),iPhone,-1"
                self.stepStringDataArray.append(errorStepString)
                return
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                if result?.count == 0 {
                    print("Step Query Count(No Data) Error, Set Error String")
                    let errorStepString = "\(Int(startTime.timeIntervalSince1970)),\(Int(end.timeIntervalSince1970)),iPhone,0"
                    self.stepStringDataArray.append(errorStepString)
                    return
                } else if let results = result {
                    print("Step Query No Error, Start Appending Results In Array")
                    for newResult in results {
                        self.stepDataArray.append(newResult)
                    }
                }
                
                print("No Error, Start Convert Step Data To String")
                for newData in self.stepDataArray {
                    let startCollectTime = Int(newData.startDate.timeIntervalSince1970)
                    let endCollectTime = Int(newData.endDate.timeIntervalSince1970)
                    let collectDevice = newData.device?.model
                    let printResultToQuantity: HKQuantitySample = newData as! HKQuantitySample
                    let collectedStepData = Int(printResultToQuantity.quantity.doubleValue(for: .count()))
                    
                    let newStepData = "\(startCollectTime),\(endCollectTime),\(collectDevice!),\(collectedStepData)"
                    
                    self.stepStringDataArray.append(newStepData)
                }
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
            if let error = error {
                print("Energy Query Error, Set Error String : \(error.localizedDescription)")
                let errorEnergyString = "\(Int(startTime.timeIntervalSince1970)),\(Int(end.timeIntervalSince1970)),iPhone,-1"
                self.energyStringDataArray.append(errorEnergyString)
                return
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                if result?.count == 0 {
                    print("Energy Query Count(No Data) Error, Set Error String")
                    let errorEnergyString = "\(Int(startTime.timeIntervalSince1970)),\(Int(end.timeIntervalSince1970)),iPhone,0"
                    self.energyStringDataArray.append(errorEnergyString)
                    return
                } else if let results = result {
                    print("Energy Query No Error, Start Appending Results In Array")
                    for newResult in results {
                        self.energyDataArray.append(newResult)
                    }
                }
                
                print("No Error, Start Convert Energy Data To String")
                for newData in self.energyDataArray {
                    let startCollectTime = Int(newData.startDate.timeIntervalSince1970)
                    let endCollectTime = Int(newData.endDate.timeIntervalSince1970)
                    let collectDevice = newData.device?.model
                    let printResultToQuantity: HKQuantitySample = newData as! HKQuantitySample
                    let collectedEnergyData = Int(printResultToQuantity.quantity.doubleValue(for: .smallCalorie()))
                    
                    let newEnergyData = "\(startCollectTime),\(endCollectTime),\(String(describing: collectDevice)),\(collectedEnergyData)"
                    
                    self.energyStringDataArray.append(newEnergyData)
                }
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
            if let error = error {
                print("Distance Query Error, Set Error String : \(error.localizedDescription)")
                let errorDistanceString = "\(Int(startTime.timeIntervalSince1970)),\(Int(end.timeIntervalSince1970)),iPhone,-1"
                self.distanceStringDataArray.append(errorDistanceString)
                return
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                if result?.count == 0 {
                    print("Distance Query Count(No Data) Error, Set Error String")
                    let errorDistanceString = "\(Int(startTime.timeIntervalSince1970)),\(Int(end.timeIntervalSince1970)),iPhone,0"
                    self.distanceStringDataArray.append(errorDistanceString)
                    return
                } else if let results = result {
                    print("Distance Query No Error, Start Appending Results In Array")
                    for newResult in results {
                        self.distanceDataArray.append(newResult)
                    }
                }
                
                print("No Error, Start Convert Distance Data To String")
                for newData in self.distanceDataArray {
                    let startCollectTime = Int(newData.startDate.timeIntervalSince1970)
                    let endCollectTime = Int(newData.endDate.timeIntervalSince1970)
                    let collectDevice = newData.device?.model
                    let printResultToQuantity: HKQuantitySample = newData as! HKQuantitySample
                    let collectedDistanceData = Int(printResultToQuantity.quantity.doubleValue(for: .meter()) * 1000)
                    
                    let newDistanceData = "\(startCollectTime),\(endCollectTime),\(collectDevice!),\(collectedDistanceData)"
                    
                    self.distanceStringDataArray.append(newDistanceData)
                }
            }
        }
        
        healthStore.execute(query)
    }
    
    // 작일 10:00:00 ~ 금일 09:59:59까지 24시간의 수면 데이터를 얻는 메소드
    func getSleepPerDay(start: Date, end: Date) {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else { return }
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)
        
        let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: nil) { [weak self] (_, result, error) -> Void in
            if let error = error {
                print("Sleep Query Error, Set Error String : \(error.localizedDescription)")
                let errorSleepString = "\(Int(start.timeIntervalSince1970)),\(Int(end.timeIntervalSince1970)),iPhone,-1"
                self?.sleepStringDataArray.append(errorSleepString)
                return
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                if result?.count == 0 {
                    print("Sleep Query Count(No Data) Error, Set Error String")
                    let errorSleepString = "\(Int(start.timeIntervalSince1970)),\(Int(end.timeIntervalSince1970)),iPhone,0"
                    self?.sleepStringDataArray.append(errorSleepString)
                    return
                } else if let results = result {
                    print("Sleep Query No Error, Start Appending Results In Array")
                    for newResult in results {
                        self?.sleepDataArray.append(newResult as! HKCategorySample)
                    }
                }
                
                print("No Error, Start Convert Sleep Data To String")
                for newData in self!.sleepDataArray {
                    let startCollectTime = Int(newData.startDate.timeIntervalSince1970)
                    let endCollectTime = Int(newData.endDate.timeIntervalSince1970)
                    let collectDeviceNumber = newData.value
                    var collectDevice = ""
                    if collectDeviceNumber == 0 {
                        collectDevice = "iPhone"
                    } else if collectDeviceNumber == 1 {
                        collectDevice = "Watch"
                    }
                    let collectedSleepTimeData =  Int(newData.endDate.timeIntervalSince(newData.startDate))
                    let newSleepData = "\(startCollectTime),\(endCollectTime),\(collectDevice ),\(collectedSleepTimeData)"
                    
                    self?.sleepStringDataArray.append(newSleepData)
                }
            }
        }
        
        healthStore.execute(query)
    }
    
    // 어제 하루의 심박 수를 가져오는 메소드
    func getHeartRatePerDay(end: Date) {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else { return }
        let startTime = Calendar.current.startOfDay(for: end)
        print(startTime)
        
        let predicate = HKQuery.predicateForSamples(withStart: startTime, end: end, options: .strictStartDate)
        
        let query = HKSampleQuery(sampleType: heartRateType, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: nil) { (_, result, error) in
            if let error = error {
                print("HeartRate Query Error, Set Error String : \(error.localizedDescription)")
                let errorHeartRateString = "\(Int(startTime.timeIntervalSince1970)),\(Int(end.timeIntervalSince1970)),iPhone,-1"
                self.heartRateStringDataArray.append(errorHeartRateString)
                return
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                if result?.count == 0 {
                    print("HeartRate Query Count(No Data) Error, Set Error String")
                    let errorHeartRateString = "\(startTime.timeIntervalSince1970),\(end.timeIntervalSince1970),iPhone,0"
                    self.heartRateStringDataArray.append(errorHeartRateString)
                    return
                } else if let results = result {
                    print("HeartRate Query No Error, Start Appending Results In Array")
                    for newResult in results {
                        self.heartRateDataArray.append(newResult)
                    }
                }
                
                print("No Error, Start Convert HeartRate Data To String")
                for newData in self.heartRateDataArray {
                    let startCollectTime = Int(newData.startDate.timeIntervalSince1970)
                    let endCollectTime = Int(newData.endDate.timeIntervalSince1970)
                    let collectDevice = newData.device?.model
                    let printResultToQuantity: HKQuantitySample = newData as! HKQuantitySample
                    let collectedHeartRateData = Int(printResultToQuantity.quantity.doubleValue(for: .count().unitDivided(by: .minute())))
                    
                    let newHeartRateData = "\(startCollectTime),\(endCollectTime),\(collectDevice!),\(collectedHeartRateData)"
                    
                    self.heartRateStringDataArray.append(newHeartRateData)
                }
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
            
            stepDataArray.removeAll()
            stepStringDataArray.removeAll()
        } else if dataType == "calories" {
            energyStringToUpload += energyStringDataArray[0]
            
            if energyStringDataArray.count > 1 {
                for dataIndex in 1..<self.energyStringDataArray.count {
                    energyStringToUpload += "," + energyStringDataArray[dataIndex]
                }
            }
            
            energyDataArray.removeAll()
            energyStringDataArray.removeAll()
        } else if dataType == "distance" {
            distanceStringToUpload += distanceStringDataArray[0]
            
            if distanceStringDataArray.count > 1 {
                for dataIndex in 1..<self.distanceStringDataArray.count {
                    distanceStringToUpload += "," + distanceStringDataArray[dataIndex]
                }
            }
            
            distanceDataArray.removeAll()
            distanceStringDataArray.removeAll()
        } else if dataType == "sleep" {
            sleepStringToUpload += sleepStringDataArray[0]
            
            if sleepStringDataArray.count > 1 {
                for dataIndex in 1..<self.sleepStringDataArray.count {
                    sleepStringToUpload += "," + sleepStringDataArray[dataIndex]
                }
            }
            
            sleepDataArray.removeAll()
            sleepStringDataArray.removeAll()
        } else if dataType == "HR" {
            heartRateStringToUpload += heartRateStringDataArray[0]
            
            if heartRateStringDataArray.count > 1 {
                for dataIndex in 1..<self.heartRateStringDataArray.count {
                    heartRateStringToUpload += "," + heartRateStringDataArray[dataIndex]
                }
            }
            
            heartRateDataArray.removeAll()
            heartRateStringDataArray.removeAll()
        }
    }
    
    //    // 건강 정보를 받아오는 루프를 생성하는 메소드
    //    func setHealthDataLoop() {
    //        let now = Date()
    //
    //        // MARK: 오늘 10시에 실행하면 어제 데이터를 받아옴(걸음/심박/거리는 00시 ~ 23:59:59, 수면은 작일 10시 ~ 금일 09:59:59). 테스트 진행 후에는 반드시 RunLoop FireTime 되돌려 놓을 것.
    //        let startTime = Calendar.current.date(bySettingHour: 00, minute: 47, second: 00, of: now)!
    //        //        let startTime = Calendar.current.date(bySettingHour: 13, minute: 19, second: 00, of: now)!
    //        print(startTime)
    //
    //        getHealthDataTimer = Timer.init(fireAt: startTime, interval: 86400, target: self, selector: #selector(healthFileUploadCheck), userInfo: nil, repeats: true)
    //
    //        print("Collecting health data loop started")
    //        print("------------------------------------------------------------")
    //        RunLoop.main.add(getHealthDataTimer, forMode: .default)
    //    }
    
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
        } else if property == "sleep" {
            if getRealm[fileIndex].lastUploadedSleepNumber == 0 {
                return false
            }
        } else if property == "HR" {
            if getRealm[fileIndex].lastUploadedHeartRateNumber == 0 {
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
    
    // 테스트 쿼리로 오류를 도출해내는 메소드
    func testHealthQuery() {
        print("Start test query")
        
        let now = Date()
        let testHour = Calendar.current.date(byAdding: .hour, value: -12, to: now)
        
        guard let testType = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return }
        
        let predicate = HKQuery.predicateForSamples(withStart: testHour, end: now, options: .strictStartDate)
        
        let query = HKSampleQuery(sampleType: testType, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: nil) { (query, result, error) in
            if let error = error {
                print("Test query error")
                if error.localizedDescription == "Protected health data is inaccessible" {
                    print("Device is locked")
                }
                self.isPhoneLock = true
            } else {
                self.isPhoneLock = false
            }
        }
        
        healthStore.execute(query)
    }
    
    // Health CSV 파일을 만들고 업로드하는 메소드
    func makeHealthCSVFileAndUpload() {
        print("Start test query in makeHealthCSVFileAndUpload")
        self.phoneLockTimer.invalidate()
        
        print("Start save and upload health data")
        
        let now = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: now)
        let yesterdayStartSleep = Calendar.current.date(bySettingHour: 10, minute: 00, second: 00, of: yesterday ?? Date())
        let todayFinishSleep = Calendar.current.date(bySettingHour: 09, minute: 59, second: 59, of: now)
        let end = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: yesterday ?? Date())
        let todayEndUnixTime = String(end!.timeIntervalSince1970)
        
        let realm = try! Realm()
        let getRealm = realm.objects(HealthRealmManager.self)
        self.indexCount = getRealm.endIndex
        
        self.indexCount += 1
        
        print("Saved Time = \(end ?? Date())")
        print("Saved UnixTime = \(todayEndUnixTime)")
        print("Now saving Realm index = \(self.indexCount)")
        
        let saveNewIndexInRealm = HealthRealmManager()
        saveNewIndexInRealm.lastSavedNumber = self.indexCount
        saveNewIndexInRealm.saveUnixTime = todayEndUnixTime
        saveNewIndexInRealm.lastUploadedStepNumber = 0
        saveNewIndexInRealm.lastUploadedEnergyNumber = 0
        saveNewIndexInRealm.lastUploadedDistanceNumber = 0
        saveNewIndexInRealm.lastUploadedSleepNumber = 0
        saveNewIndexInRealm.lastUploadedHeartRateNumber = 0
        
        try! realm.write {
            realm.add(saveNewIndexInRealm)
        }
        
        self.getStepCountPerDay(end: end!)
        self.getActiveEnergyPerDay(end: end!)
        self.getDistanceWalkAndRunPerDay(end: end!)
        self.getSleepPerDay(start: yesterdayStartSleep!, end: todayFinishSleep!)
        self.getHeartRatePerDay(end: end!)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            for array in self.healthContainerNameArray {
                self.makeHealthDataString(dataType: array)
            }
            
            CSVFileManager.shared.writeHealthCSV(sensorData: self.stepStringToUpload, dataType: "steps", index: self.indexCount)
            CSVFileManager.shared.writeHealthCSV(sensorData: self.energyStringToUpload, dataType: "calories", index: self.indexCount)
            CSVFileManager.shared.writeHealthCSV(sensorData: self.distanceStringToUpload, dataType: "distance", index: self.indexCount)
            CSVFileManager.shared.writeHealthCSV(sensorData: self.sleepStringToUpload, dataType: "sleep", index: self.indexCount)
            CSVFileManager.shared.writeHealthCSV(sensorData: self.heartRateStringToUpload, dataType: "HR", index: self.indexCount)
            
            self.stepStringToUpload = ""
            self.energyStringToUpload = ""
            self.distanceStringToUpload = ""
            self.sleepStringToUpload = ""
            self.heartRateStringToUpload = ""
            
            CSVFileManager.shared.checkInternetAndStartUploadHealthData()
        }
    }
    
    // MARK: - @objc Method
    // 앱 재시작 후 잔여 파일을 모두 업로드하기 위한 메소드
    @objc private func reuploadFiles() {
        if NetWorkManager.shared.isConnected == true {
            for index in checkWhenReStartHealthDatas()..<getLastIndexOfHealthRealm() + 1 {
                for containerName in healthContainerNameArray {
                    if checkHealthDataUploaded(property: containerName, fileIndex: index) == false {
                        if checkHealthCSVExist(fileName: containerName, fileIndex: index) == false {
                            let realm = try! Realm()
                            
                            let changeRealm = realm.object(ofType: HealthRealmManager.self, forPrimaryKey: index)
                            
                            let notUploadedUnixTimeString = changeRealm?.saveUnixTime
                            let notUploadedUnixTime = Double(notUploadedUnixTimeString ?? "SavedUnixTime in Realm Error")
                            let notUploadedDate = Date(timeIntervalSince1970: notUploadedUnixTime!)
                            
                            if containerName == "steps" {
                                getStepCountPerDay(end: notUploadedDate)
                                DispatchQueue.main.async {
                                    self.makeHealthDataString(dataType: "steps")
                                    CSVFileManager.shared.writeHealthCSV(sensorData: self.stepStringToUpload, dataType: "steps", index: index)
                                    self.stepStringToUpload = ""
                                }
                            } else if containerName == "calories" {
                                getActiveEnergyPerDay(end: notUploadedDate)
                                DispatchQueue.main.async {
                                    self.makeHealthDataString(dataType: "calories")
                                    CSVFileManager.shared.writeHealthCSV(sensorData: self.energyStringToUpload, dataType: "calories", index: index)
                                    self.energyStringToUpload = ""
                                }
                            } else if containerName == "distance" {
                                getDistanceWalkAndRunPerDay(end: notUploadedDate)
                                DispatchQueue.main.async {
                                    self.makeHealthDataString(dataType: "distance")
                                    CSVFileManager.shared.writeHealthCSV(sensorData: self.distanceStringToUpload, dataType: "distance", index: index)
                                    self.distanceStringToUpload = ""
                                }
                            } else if containerName == "sleep" {
                                let startTime = Calendar.current.date(bySettingHour: 10, minute: 00, second: 00, of: notUploadedDate)
                                let endYesterday = Calendar.current.date(byAdding: .day, value: +1, to: notUploadedDate)
                                let endTime = Calendar.current.date(bySettingHour: 09, minute: 59, second: 59, of: endYesterday!)
                                getSleepPerDay(start: startTime!, end: endTime!)
                                DispatchQueue.main.async {
                                    self.makeHealthDataString(dataType: "sleep")
                                    CSVFileManager.shared.writeHealthCSV(sensorData: self.sleepStringToUpload, dataType: "sleep", index: index)
                                    self.sleepStringToUpload = ""
                                }
                            } else if containerName == "HR" {
                                getHeartRatePerDay(end: notUploadedDate)
                                DispatchQueue.main.async {
                                    self.makeHealthDataString(dataType: "HR")
                                    CSVFileManager.shared.writeHealthCSV(sensorData: self.heartRateStringToUpload, dataType: "HR", index: index)
                                    self.sleepStringToUpload = ""
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
    }
    
//        // 앱 잠금을 파악하고 건강 데이터 생성/업로드를 지시하는 메소드
//        @objc func healthFileUploadCheck() {
//            print("Set health file upload timer")
//            phoneLockTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(makeHealthCSVFileAndUpload), userInfo: nil, repeats: true)
//        }
    
}
