//
//  Album.swift
//  poporazzi
//
//  Created by 김민준 on 4/9/25.
//

import Foundation

struct Album {
    var title: String
    var trackingStartDate: Date
    
    static var initialValue: Self {
        Album(title: "", trackingStartDate: .now)
    }
}
