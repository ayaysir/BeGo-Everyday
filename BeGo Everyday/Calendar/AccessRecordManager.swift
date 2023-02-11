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
    
    static func addCurrentDate() {
        var appOpenArray = UserDefaults.standard.array(forKey: APP_OPEN_DATES) ?? []
        appOpenArray.append(Date())
        
        // 한번만 (테스트용)
        // appOpenArray.append(Date(timeIntervalSince1970: 1675090800))
        // appOpenArray.append(Date(timeIntervalSince1970: 1675177200))
        // appOpenArray.append(Date(timeIntervalSince1970: 1675263600))
        // 
        // appOpenArray.append(Date(timeIntervalSince1970: 1675522800))
        // 
        // appOpenArray.append(Date(timeIntervalSince1970: 1677769200))
        // appOpenArray.append(Date(timeIntervalSince1970: 1677769200 + 86400))
        // appOpenArray.append(Date(timeIntervalSince1970: 1677769200 + 86400 * 2))
        
        UserDefaults.standard.set(appOpenArray, forKey: APP_OPEN_DATES)
    }
}

