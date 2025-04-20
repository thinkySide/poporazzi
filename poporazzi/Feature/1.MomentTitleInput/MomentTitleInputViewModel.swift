//
//  MomentTitleInputViewModel.swift
//  poporazzi
//
//  Created by 김민준 on 4/5/25.
//

import Foundation
import RxSwift
import RxCocoa

final class MomentTitleInputViewModel: ViewModel {
    
    private let disposeBag = DisposeBag()
    
    struct Input {
        let titleTextChanged: Signal<String>
        let startButtonTapped: Signal<Void>
    }
    
    struct Output {
        let titleText: Signal<String>
        let isStartButtonEnabled: Signal<Bool>
        let didNavigateToRecord: Signal<Record>
    }
    
    let titleText = BehaviorRelay<String>(value: "")
    let isStartButtonEnabled = PublishRelay<Bool>()
    let navigateToRecord = PublishRelay<Record>()
}

// MARK: - Transform

extension MomentTitleInputViewModel {
    
    func transform(_ input: Input) -> Output {
        input.titleTextChanged
            .emit(to: titleText)
            .disposed(by: disposeBag)
        
        input.titleTextChanged
            .map { !$0.isEmpty }
            .emit(to: isStartButtonEnabled)
            .disposed(by: disposeBag)
        
        input.startButtonTapped
            .withUnretained(self)
            .map { owner, _ in Record(title: owner.titleText.value, trackingStartDate: .now) }
            .emit(with: self) { owner, record in
                UserDefaultsService.albumTitle = record.title
                UserDefaultsService.trackingStartDate = record.trackingStartDate
                UserDefaultsService.isTracking = true
                owner.navigateToRecord.accept((record))
            }
            .disposed(by: disposeBag)
        
        return Output(
            titleText: titleText.asSignal(onErrorJustReturn: ""),
            isStartButtonEnabled: isStartButtonEnabled.asSignal(),
            didNavigateToRecord: navigateToRecord.asSignal()
        )
    }
}
