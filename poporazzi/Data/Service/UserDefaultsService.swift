//
//  UserDefaultsService.swift
//  poporazzi
//
//  Created by 김민준 on 4/5/25.
//

import Foundation
import RxSwift

/// UserDefaults 관리 객체
struct UserDefaultsService {
    
    @UserDefault(key: "isTracking", defaultValue: false)
    static var isTracking: Bool
    
    @UserDefault(key: "albumTitle", defaultValue: "")
    static var albumTitle: String
    
    @UserDefault(key: "trackingStartDate", defaultValue: .now)
    static var trackingStartDate: Date
//    
//    static var record: Record {
//        get {
//            Record(title: albumTitle, trackingStartDate: trackingStartDate)
//        } set {
//            UserDefaultsService.albumTitle = newValue.title
//            UserDefaultsService.trackingStartDate = newValue.trackingStartDate
//        }
//    }
}

// MARK: - propertyWrapper

@propertyWrapper
struct UserDefault<T> {
    
    let key: String
    let defaultValue: T
    
    init(key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }
    
    var wrappedValue: T {
        get {
            UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
        } set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}
