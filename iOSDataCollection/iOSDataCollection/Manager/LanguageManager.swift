//
//  LanguageManager.swift
//  iOSDataCollection
//
//  Created by ROLF J. on 2022/08/24.
//

import Foundation

public extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}

