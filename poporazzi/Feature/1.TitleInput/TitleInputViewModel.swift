//
//  TitleInputViewModel.swift
//  poporazzi
//
//  Created by 김민준 on 4/5/25.
//

import Foundation
import RxSwift
import RxCocoa

final class TitleInputViewModel: ViewModel {
    
    private let disposeBag = DisposeBag()
    
    struct Input {
        let titleTextChanged: Signal<String>
        let startButtonTapped: Signal<Void>
    }
    
    struct Output {
        let titleText: Signal<String>
        let isStartButtonEnabled: Signal<Bool>
        let didNavigateToRecord: Signal<Void>
    }
    
    private let titleText = BehaviorRelay<String>(value: "")
    private let isStartButtonEnabled = PublishRelay<Bool>()
    private let navigateToRecord = PublishRelay<Void>()
}

// MARK: - Transform

extension TitleInputViewModel {
    
    func transform(_ input: Input) -> Output {
        input.titleTextChanged
            .emit(to: titleText)
            .disposed(by: disposeBag)
        
        input.titleTextChanged
            .map { !$0.isEmpty }
            .emit(to: isStartButtonEnabled)
            .disposed(by: disposeBag)
        
        input.startButtonTapped
            .emit(with: self) { owner, _ in
                UserDefaultsService.isTracking = true
                UserDefaultsService.albumTitle = owner.titleText.value
                UserDefaultsService.trackingStartDate = .now
                owner.navigateToRecord.accept(())
            }
            .disposed(by: disposeBag)
        
        return Output(
            titleText: titleText.asSignal(onErrorJustReturn: ""),
            isStartButtonEnabled: isStartButtonEnabled.asSignal(),
            didNavigateToRecord: navigateToRecord.asSignal()
        )
    }
}
