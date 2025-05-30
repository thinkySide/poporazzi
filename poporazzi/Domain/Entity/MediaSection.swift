//
//  MediaSection.swift
//  poporazzi
//
//  Created by 김민준 on 5/28/25.
//

import Foundation

typealias SectionMediaList = [(MediaSection, [Media])]

enum MediaSection: Hashable, Comparable {
    case day(order: Int, date: Date)
    
    /// DateFormat을 반환합니다.
    var dateFormat: String {
        switch self {
        case let .day(order, date):
            "\(order)일차"
        }
    }
    
    static func < (lhs: MediaSection, rhs: MediaSection) -> Bool {
        switch (lhs, rhs) {
        case let (.day(order1, _), .day(order2, _)):
            return order1 < order2
        }
    }
}
