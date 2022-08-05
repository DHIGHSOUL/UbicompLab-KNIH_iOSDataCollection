//
//  HealthDataManager.swift
//  iOSDataCollection
//
//  Created by ROLF J. on 2022/08/02.
//

import Foundation
import HealthKit

class HealthDataManager {
    
    static let shared = HealthDataManager()
    
    let healthStore = HKHealthStore()
    
    // MARK: - Instance member
    // Health 데이터들을 업로드하기 위한 타이머
    var uploadHealthDataTimer = Timer()
    
    // 컨테이너 이름 배열
    let containerNameArray: [String] = ["steps", "calories"]
    
    // MARK: - Method
    // 건강 정보를 읽기 위해 사용자의 허가를 얻기 위한 메소드
    func requestHealthDataAuthorization() {
        if HKHealthStore.isHealthDataAvailable() {
            let read = Set([HKObjectType.quantityType(forIdentifier: .heartRate)!, HKObjectType.quantityType(forIdentifier: .stepCount)!])
            let share = Set([HKObjectType.quantityType(forIdentifier: .heartRate)!, HKObjectType.quantityType(forIdentifier: .stepCount)!])
            
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
    
    // 일별로 걸음 수를 얻는 메소드
    func getStepCountPerDay(end: Date) {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return }
        let startDate = Calendar.current.startOfDay(for: end)
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: end, options: .strictStartDate)
        
        var stepSum: Double = 0.0
        
        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { (_, result, error) in
            guard let result = result, let sum = result.sumQuantity() else {
                print("Fail to get step")
                return
            }
            
            stepSum = sum.doubleValue(for: HKUnit.count())
            let startUnixTime = startDate.timeIntervalSince1970
            let endUnixTime = end.timeIntervalSince1970
            
            let stepString = "\(Int(startUnixTime)),\(Int(endUnixTime)),\(String(Int(stepSum)))"
            
            print("걸음 수 : \(stepString)")
            UserDefaults.standard.setValue(stepString, forKey: "step")
        }
        
        healthStore.execute(query)
    }
    
    // 일별로 사용한 에너지(칼로리)를 얻는 메소드
    func getBurnedEnergyPerDay(end: Date) {
        guard let energyType = HKSampleType.quantityType(forIdentifier: .activeEnergyBurned) else { return }
        let startDate = Calendar.current.startOfDay(for: end)
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: end, options: .strictStartDate)
        
        var energySum: Double = 0.0
        
        let query = HKStatisticsQuery(quantityType: energyType, quantitySamplePredicate: predicate, options: .cumulativeSum) { (_, result, error) in
            guard let result = result, let sum = result.sumQuantity() else {
                print("Fail to get Calorie")
                return
            }
            
            energySum = sum.doubleValue(for: HKUnit.kilocalorie())
            let startUnixTime = startDate.timeIntervalSince1970
            let endUnixTime = end.timeIntervalSince1970
            
            let energyString = "\(Int(startUnixTime)),\(Int(endUnixTime)),\(String(Int(energySum)))"
            
            print("소비 에너지 : \(energyString)")
            UserDefaults.standard.setValue(energyString, forKey: "calories")
        }
        
        healthStore.execute(query)
    }
    
    // 건강 정보를 받아오는 루프를 생성하는 메소드
    func getHealthDataLoop() {
        let calender = Calendar.current
        
        let startTime = Date()
        let getDataTime = calender.date(bySettingHour: 23, minute: 59, second: 59, of: startTime)!
        
        var getHealthDataTimer = Timer()
        
        getHealthDataTimer = Timer.init(fireAt: getDataTime, interval: 86400, target: self, selector: #selector(getHealthDatas), userInfo: nil, repeats: true)
        
        print("Loop Started")
        print("------------------------------------------------------------")
        RunLoop.main.add(getHealthDataTimer, forMode: .common)
    }
    
    // MARK: - @objc Method
    // Health 데이터들을 가져오는 메소드
    @objc func getHealthDatas() {
        let now = Date()
        
        getStepCountPerDay(end: now)
        getBurnedEnergyPerDay(end: now)
        
        uploadHealthDataTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(uploadHealthDatas), userInfo: nil, repeats: true)
    }
    
    // TODO: 서버에 관련 컨터이너 만들어야 함 -
    // 인터넷 연결이 감지되면 UserDefaults DB에 저장되어 있는 Health 데이터들을 업로드하는 메소드
    @objc func uploadHealthDatas() {
        if NetWorkManager.shared.isConnected == true {
            for containerName in containerNameArray {
                if UserDefaults.standard.string(forKey: containerName) != "" {
                    let semaphore = DispatchSemaphore (value: 0)
                    
                    let parameters = "{\n    \"m2m:cin\": {\n        \"con\": \"\(String(describing: UserDefaults.standard.string(forKey: containerName)))\"\n    }\n}"
                    let postData = parameters.data(using: .utf8)
                    
                    let userID = UserDefaults.standard.string(forKey: "ID")!
                    
                    var request = URLRequest(url: URL(string: "http://114.71.220.59:7579/Mobius/\(String(describing: userID))/health/\(containerName)")!,timeoutInterval: Double.infinity)
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
                        
                        print("\(containerName) Data is served.")
                        UserDefaults.standard.setValue("", forKey: containerName)
                        semaphore.signal()
                    }
                    task.resume()
                    semaphore.wait()
                }
            }
            uploadHealthDataTimer.invalidate()
        }
    }
    
}
