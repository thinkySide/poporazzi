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
    
    /// 날짜 비교용 포맷을 반환합니다.
    var compareFormat: String {
        Date.dateFormatter.dateFormat = "yyyy-MM-dd"
        return Date.dateFormatter.string(from: self)
    }
    
    /// 시작 날짜 포맷을 반환합니다.
    var startDateFormat: String {
        Date.dateFormatter.dateFormat = "yyyy년 M월 d일 EEEE~"
        return Date.dateFormatter.string(from: self)
    }
    
    /// 시작 날짜 전체 포맷을 반환합니다.
    var startDateFullFormat: String {
        Date.dateFormatter.dateFormat = "yyyy년 M월 d일 EEEE a h시 mm분~"
        return Date.dateFormatter.string(from: self)
    }
    
    /// Section의 Header 포맷을 반환합니다.
    var sectionHeaderFormat: String {
        Date.dateFormatter.dateFormat = "M월 d일 EEEE"
        return Date.dateFormatter.string(from: self)
    }
}

// MARK: - TimeInterval

extension TimeInterval {
    
    /// 영상 길이 포맷을 반환합니다.
    var videoDurationFormat: String {
        let time = Int(self)
        let minutes = time / 60
        let seconds = time % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
