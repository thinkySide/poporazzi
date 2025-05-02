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
    
    /// 의존 객체를 담는 배열
    private var dependencies = [String: Any]()
    
    /// 객체를 등록합니다.
    func register<T>(_ dependency: T) {
        let key = key(from: T.self)
        dependencies[key] = dependency
    }
    
    /// 객체를 꺼내옵니다.
    func resolve<T>() -> T {
        let key = key(from: T.self)
        guard let dependency = dependencies[key] else {
            fatalError("\(key): 등록되지 않은 객체")
        }
        return dependency as! T
    }
}

// MARK: - Injection

extension DIContainer {
    
    /// 전체 의존성을 주입합니다.
    func injectDependencies() {
        register(LiveActivityService())
        register(PhotoKitService())
    }
}

// MARK: - Helper

extension DIContainer {
    
    /// Dependency에 대한 Key를 생성합니다.
    private func key<T>(from dependency: T) -> String {
        String(describing: type(of: T.self))
    }
}

// MARK: - PropertyWrapper

@propertyWrapper
final class Dependency<T> {
    
    let wrappedValue: T
    
    init() {
        self.wrappedValue = DIContainer.shared.resolve()
    }
}
