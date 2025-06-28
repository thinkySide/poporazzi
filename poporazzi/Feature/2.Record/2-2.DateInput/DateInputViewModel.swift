//
//  DateInputViewModel.swift
//  poporazzi
//
//  Created by 김민준 on 5/13/25.
//

import Foundation
import RxSwift
import RxCocoa

final class DateInputViewModel: ViewModel {
    
    @Dependency(\.persistenceService) var persistenceService
    @Dependency(\.photoKitService) var photoKitService
    @Dependency(\.liveActivityService) var liveActivityService
    
    private let disposeBag = DisposeBag()
    private let output: Output
    
    let navigation = PublishRelay<Navigation>()
    
    init(output: Output) {
        self.output = output
    }
    
    deinit {
        Log.print(#file, .deinit)
    }
}

// MARK: - Input & Output

extension DateInputViewModel {
    
    struct Input {
        let backButtonTapped: Signal<Void>
        let startButtonTapped: Signal<Void>
    }
    
    struct Output {
        let titleText: BehaviorRelay<String>
        let startDate = BehaviorRelay<Date?>(value: nil)
        let endDate = BehaviorRelay<Date?>(value: nil)
    }
    
    enum Navigation {
        case pop
        case startRecord(Record)
    }
}

// MARK: - Transform

extension DateInputViewModel {
    
    func transform(_ input: Input) -> Output {
        input.backButtonTapped
            .emit(with: self) { owner, _ in
                owner.navigation.accept(.pop)
            }
            .disposed(by: disposeBag)
        
        input.startButtonTapped
            .emit(with: self) { owner, _ in
                owner.startRecord()
            }
            .disposed(by: disposeBag)
        
        return output
    }
}

// MARK: - Helper

extension DateInputViewModel {
    
    /// 기록을 시작합니다.
    private func startRecord() {
        let album = Record(
            title: output.titleText.value,
            mediaFetchOption: .all,
            mediaFilterOption: .init()
        )
        
        navigation.accept(.startRecord(album))
        liveActivityService.start(to: album)
        HapticManager.notification(type: .success)
        
        try? persistenceService.createAlbum(from: album)
        UserDefaultsService.trackingAlbumId = album.id
    }
}
