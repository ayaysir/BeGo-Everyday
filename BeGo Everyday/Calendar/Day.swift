//
//  Day.swift
//  LanguageWeb
//
//  Created by yoonbumtae on 2023/02/04.
//

import Foundation

struct Day {
    /// Date 인스턴스.
    let date: Date
    
    /// 화면에 표시될 숫자.
    /// 예) Date 인스턴스가 2022년 1월 25일이라면 -> 25
    let number: String
    
    /// 이 날짜가 선택되었는지 여부.
    let isSelected: Bool
    
    /// 이 날짜가 현재 달 내에 있는지 추적.
    /// 예) 1월 달력을 그리고자 할 떄 Date 인스턴스가 1월 25일이라면 true, 2월 1일이라면 false
    let isWithinDisplayedMonth: Bool
}
