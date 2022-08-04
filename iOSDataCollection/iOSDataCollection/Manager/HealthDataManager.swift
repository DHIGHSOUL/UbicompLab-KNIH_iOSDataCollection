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
    
    // MARK: - Method
    // 건강 정보를 읽기 위해 사용자의 허가를 얻기 위한 메소드
    func requestHealthDataAuthorization() {
        if HKHealthStore.isHealthDataAvailable() {
            let read = Set([HKObjectType.quantityType(forIdentifier: .heartRate)!, HKObjectType.quantityType(forIdentifier: .stepCount)!])
            let share = Set([HKObjectType.quantityType(forIdentifier: .heartRate)!, HKObjectType.quantityType(forIdentifier: .stepCount)!])
            
            healthStore.requestAuthorization(toShare: share, read: read) { (success, error) in
                if error != nil {
                    print(error?.localizedDescription ?? "HealthKit Error")
                } else {
                    if success {
                        print("HealthKit 권한이 허가되었습니다.")
                    } else {
                        print("HealthKit 권한이 없습니다.")
                    }
                }
            }
        }
    }
    
    // 일별로 걸음 수를 얻는 메소드
    func getStepCountPerDay() {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return }
        let now = Date()
        let startDate = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: now, options: .strictStartDate)
        
        var stepSum: Double = 0.0
        
        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { (_, result, error) in
            guard let result = result, let sum = result.sumQuantity() else {
                print("Fail to get step")
                return
            }
            
            stepSum = sum.doubleValue(for: HKUnit.count())
            
            print("시작 시간 : \(startDate)")
            print("종료 시간 : \(now)")
            print("걸음 수 : \(Int(stepSum))")
        }
        
        healthStore.execute(query)
    }
    
    // 일별로 사용한 에너지(칼로리)를 얻는 메소드
    func getBurnedEnergyPerDay() {
        guard let energyType = HKSampleType.quantityType(forIdentifier: .activeEnergyBurned) else { return }
        let now = Date()
        let startDate = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: now, options: .strictStartDate)
        
        var energySum: Double = 0.0
        
        let query = HKStatisticsQuery(quantityType: energyType, quantitySamplePredicate: predicate, options: .cumulativeSum) { (_, result, error) in
            guard let result = result, let sum = result.sumQuantity() else {
                print("Fail to get Calorie")
                return
            }
            
            energySum = sum.doubleValue(for: HKUnit.kilocalorie())
            
            print("시작 시간 : \(startDate)")
            print("종료 시간 : \(now)")
            print("소비 에너지 : \(Int(energySum))")
        }
        
        healthStore.execute(query)
    }
    
    // 건강 정보를 받아오는 루프를 생성하는 메소드
    func getHealthDataLoop() {
        print("------------------------------------------------------------")
        print(Date.now)
        print("------------------------------------------------------------")
        
        let calender = Calendar.current
        
        let now = Date()
        let getDataTime = calender.date(bySettingHour: 00, minute: 00, second: 00, of: now)!
        
        var getHealthDataTimer = Timer()
        
        getHealthDataTimer = Timer.init(fireAt: getDataTime, interval: 10, target: self, selector: #selector(getHealthDatas), userInfo: nil, repeats: true)
        
        print("Loop Started")
        print("------------------------------------------------------------")
        RunLoop.main.add(getHealthDataTimer, forMode: .common)
    }
    
    // MARK: - @objc Method
    @objc func getHealthDatas() {
        getStepCountPerDay()
        getBurnedEnergyPerDay()
    }
    
}
