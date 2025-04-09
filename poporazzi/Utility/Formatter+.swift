//
//  Formatter+.swift
//  poporazzi
//
//  Created by 김민준 on 4/8/25.
//

import Foundation

// MARK: - Date

extension Date {
    
    /// 공용 DateFormatter
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter
    }()
    
    /// 시작 날짜 포맷을 반환합니다.
    var startDateFormat: String {
        Date.dateFormatter.dateFormat = "yyyy년 M월 d일 E요일 H시 m분 ~"
        return Date.dateFormatter.string(from: self)
    }
}
