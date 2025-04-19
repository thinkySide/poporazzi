//
//  SharedState.swift
//  poporazzi
//
//  Created by 김민준 on 4/19/25.
//

import Foundation
import RxSwift
import RxCocoa

/// 공유 상태 관리를 위한 클래스
final class SharedState {
    
    private let disposeBag = DisposeBag()
    
    /// 기록 정보
    let record: BehaviorRelay<Record>
    
    /// 기록 중인지 여부
    let isTracking: BehaviorRelay<Bool>
    
    init() {
        let lastTitle = UserDefaultsService.albumTitle
        let lastTrackingStartDate = UserDefaultsService.trackingStartDate
        record = .init(value: .init(title: lastTitle, trackingStartDate: lastTrackingStartDate))
        isTracking = .init(value: UserDefaultsService.isTracking)
        bind()
    }
}

// MARK: - Binding

extension SharedState {
    
    private func bind() {
        
    }
}
