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

enum AlbumSaveOption {
    
    /// 하나로 저장
    case saveAsSingle
    
    /// 일차별 저장
    case saveByDay
}
