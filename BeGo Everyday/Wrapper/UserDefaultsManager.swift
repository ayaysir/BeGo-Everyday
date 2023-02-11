//
//  UserDefaultsManager.swift
//  BeGo Everyday
//
//  Created by yoonbumtae on 2023/02/11.
//

import CoreLocation

func loadCoordFromUserDefaults() -> CLLocationCoordinate2D? {
    guard let coordinateText = UserDefaults.standard.string(forKey: SELECTED_COORDINATE) else {
        print(#function, "Saved coordinate doesn't exist.")
        return nil
    }
    
    // lat(위도), lon(경도)
    let coordTextArr = coordinateText.split(separator: ";")
    guard let latitude = Double(coordTextArr[0]),
          let longitude = Double(coordTextArr[1]) else {
        print(#function, "Failed to convert coordinate type.")
        return nil
    }
    
    return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
}
