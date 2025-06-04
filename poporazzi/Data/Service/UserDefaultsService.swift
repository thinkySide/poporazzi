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
    
    @UserDefault(key: "trackingAlbumId", defaultValue: "")
    static var trackingAlbumId: String
    
    @UserDefault(key: "isFirstLaunch", defaultValue: true)
    static var isFirstLaunch: Bool
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
