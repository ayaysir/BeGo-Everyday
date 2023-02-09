//
//  MonthMetadata.swift
//  LanguageWeb
//
//  Created by yoonbumtae on 2023/02/04.
//

import Foundation

struct MonthMetadata {
    /// 해당 달의 총 일수, 예를 들어 1월은 31일까지 있으므로 31
    let numberOfDays: Int
    
    /// 해당 달의 첫 Date
    let firstDay: Date
    
    /// 해당 달의 첫 Date가 무슨 요일인지 반환, 일 ~ 토 => 1 ~ 7
    /// 예) 수요일이라면 4
    let firstDayWeekday: Int
}
