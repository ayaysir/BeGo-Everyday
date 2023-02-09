//
//  AccessRecordManager.swift
//  LanguageWeb
//
//  Created by yoonbumtae on 2023/02/08.
//

import Foundation

class AccessRecordManager {
    private let appOpenArray: [Date]
    
    init?() {
        guard let appOpenArray = (UserDefaults.standard.array(forKey: APP_OPEN_DATES) ?? []) as? [Date] else {
            return nil
        }
        self.appOpenArray = appOpenArray
    }
    
    func findAccessDateComponents(_ component: DateComponents) -> Bool {
        let compSet = Set(appOpenArray.map { $0.get(.year, .month, .day) })
        return compSet.contains(component)
    }
}

