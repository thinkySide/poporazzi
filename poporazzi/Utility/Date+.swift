//
//  Date+.swift
//  poporazzi
//
//  Created by 김민준 on 5/17/25.
//

import Foundation

extension Date {
    
    /// 10분 단위로 반내림 후 반환합니다.
    var roundDownMinutes: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: self)
        
        var newComponents = components
        newComponents.minute = (components.minute ?? 0) / 10 * 10
        newComponents.second = 0
        return calendar.date(from: newComponents) ?? self
    }
}
