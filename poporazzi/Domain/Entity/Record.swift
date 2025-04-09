//
//  Record.swift
//  poporazzi
//
//  Created by 김민준 on 4/9/25.
//

import Foundation

struct Record {
    var title: String
    var trackingStartDate: Date
    
    static var initialValue: Self {
        Record(title: "", trackingStartDate: .now)
    }
}
