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
    private var dependencies: Dependencies!
    
    /// 의존성 리스트
    struct Dependencies {
        let liveActivityService: LiveActivityInterface
        let photoKitService: PhotoKitInterface
        let storeKitService: StoreKitServiceInterface
    }
    
    /// 객체를 꺼내옵니다.
    fileprivate func resolve<T>(_ keyPath: KeyPath<Dependencies, T>) -> T {
        dependencies[keyPath: keyPath]
    }
}

// MARK: - Inject

extension DIContainer {
    
    /// 주입 할 객체를 반환합니다.
    enum InjectObject {
        case liveValue
        case testValue
        
        /// 의존성 객체
        var dependencies: Dependencies {
            switch self {
            case .liveValue: .init(
                liveActivityService: LiveActivityService(),
                photoKitService: PhotoKitService(),
                storeKitService: StoreKitService()
            )
            case .testValue: .init(
                liveActivityService: MockLiveActivityService(),
                photoKitService: MockPhotoKitService(),
                storeKitService: MockStoreKitService()
            )
            }
        }
    }
    
    /// 의존성을 주입합니다.
    func inject(_ injectObject: InjectObject) {
        dependencies = injectObject.dependencies
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
