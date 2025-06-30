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
    static let dateFormatter = DateFormatter()
    
    /// 로컬라이징된 문자열을 반환합니다.
    private func localizedString(_ template: String) -> String {
        let formatter = Date.dateFormatter
        formatter.locale = .current
        formatter.calendar = .current
        formatter.timeZone = .current
        formatter.setLocalizedDateFormatFromTemplate(template)
        return formatter.string(from: self)
    }
    
    /// 날짜 비교용 포맷을 반환합니다.
    var compareFormat: String {
        localizedString("yyyy-MM-dd")
    }
    
    /// 기본 포맷을 반환합니다.
    var compactFormat: String {
        localizedString("yyMd")
    }
    
    /// 시작 날짜 포맷을 반환합니다.
    var startDateFormat: String {
        localizedString("yyyyMMMMdEEEE") + " ~"
    }
    
    /// 시작 날짜 전체 포맷을 반환합니다.
    var startDateFullFormat: String {
        localizedString("yyyyMMMMdEEEEa h:mm")
    }
    
    /// 종료 날짜 전체 포맷을 반환합니다.
    var endDateFullFormat: String {
        localizedString("yyyyMMMMdEEEEa h:mm")
    }
    
    /// Section의 Header 포맷을 반환합니다.
    var sectionHeaderFormat: String {
        localizedString("MMMMdEEEE")
    }
    
    /// Section의 Header 포맷을 반환합니다.
    var detailFormat: String {
        localizedString("yyyyMMMMdEEEE")
    }

    
    /// album 날짜 포맷을 반환합니다.
    var albumFormat: String {
        Date.dateFormatter.dateFormat = "yyMMdd"
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
