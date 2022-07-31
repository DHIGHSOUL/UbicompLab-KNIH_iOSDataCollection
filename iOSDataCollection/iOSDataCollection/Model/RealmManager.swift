//
//  RealmManager.swift
//  iOSDataCollection
//
//  Created by ROLF J. on 2022/07/29.
//

import Foundation
import RealmSwift

class RealmManager: Object {
    @objc dynamic var lastSavedNumber: Int = 0
    
    override class func primaryKey() -> String? {
        return "lastSavedNumber"
    }
}
