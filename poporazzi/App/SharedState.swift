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
    
    init() {
        let title = UserDefaultsService.albumTitle
        let trackingStartDate = UserDefaultsService.trackingStartDate
        let lastRecord = Record(title: title, trackingStartDate: trackingStartDate)
        record = .init(value: lastRecord)
        bind()
    }
}

// MARK: - Binding

extension SharedState {
    
    private func bind() {
        record
            .bind(with: self) { owner, record in
                UserDefaultsService.albumTitle = record.title
                UserDefaultsService.trackingStartDate = record.trackingStartDate
            }
            .disposed(by: disposeBag)
    }
}
