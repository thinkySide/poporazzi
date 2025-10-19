//
//  FirebaseManager.swift
//  poporazzi
//
//  Created by 김민준 on 10/19/25.
//

import FirebaseCore

enum FirebaseManager {
    
    /// Firebase를 초기화합니다.
    static func initialize() {
        FirebaseApp.configure()
    }
}
