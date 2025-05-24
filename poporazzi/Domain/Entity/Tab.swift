//
//  Tab.swift
//  poporazzi
//
//  Created by 김민준 on 5/24/25.
//

import Foundation

enum Tab {
    case albumList
    case record(isTracking: Bool)
    case settings
    
    var index: Int {
        switch self {
        case .albumList: 0
        case .record: 1
        case .settings: 2
        }
    }
}
