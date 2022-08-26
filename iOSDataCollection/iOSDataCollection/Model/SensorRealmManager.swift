//
//  SensorRealmManager.swift
//  iOSDataCollection
//
//  Created by ROLF J. on 2022/07/29.
//

import Foundation
import RealmSwift
import Realm

class SensorRealmManager: Object {
    @objc dynamic var lastSavedNumber: Int = 0
    @objc dynamic var lastUploadedmAccNumber: Int = 0
    @objc dynamic var lastUploadedmGyrNumber: Int = 0
    @objc dynamic var lastUploadedmPreNumber: Int = 0
    
    override class func primaryKey() -> String? {
        return "lastSavedNumber"
    }
}
