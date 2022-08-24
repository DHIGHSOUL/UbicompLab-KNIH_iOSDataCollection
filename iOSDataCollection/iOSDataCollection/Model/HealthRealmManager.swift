//
//  HealthRealmManager.swift
//  iOSDataCollection
//
//  Created by ROLF J. on 2022/08/20.
//

import Foundation
import RealmSwift

class HealthRealmManager: Object {
    @objc dynamic var lastSavedNumber: Int = 0
    @objc dynamic var saveUnixTime: String = ""
    @objc dynamic var lastUploadedStepNumber: Int = 0
    @objc dynamic var lastUploadedEnergyNumber: Int = 0
    @objc dynamic var lastUploadedDistanceNumber: Int = 0
    @objc dynamic var lastUploadedSleepNumber: Int = 0
    @objc dynamic var lastUploadedHeartRateNumber: Int = 0
    
    override class func primaryKey() -> String? {
        return "lastSavedNumber"
    }
}
