//
//  DIContainer.swift
//  poporazzi
//
//  Created by 김민준 on 5/2/25.
//

import Foundation

final class DIContainer {
    
    /// 싱글톤
    static let shared = DIContainer()
    private init() {}
    
    /// 의존성이 담긴 객체
    private let dependencies = Dependencies()
    
    /// 의존성 리스트
    final class Dependencies {
        let liveActivityService = LiveActivityService()
        let photoKitService = PhotoKitService()
    }
    
    /// 객체를 꺼내옵니다.
    fileprivate func resolve<T>(_ keyPath: KeyPath<Dependencies, T>) -> T {
        dependencies[keyPath: keyPath]
    }
}

// MARK: - PropertyWrapper

@propertyWrapper
final class Dependency<T> {
    
    let wrappedValue: T
    
    init(_ keyPath: KeyPath<DIContainer.Dependencies, T>) {
        self.wrappedValue = DIContainer.shared.resolve(keyPath)
    }
}
