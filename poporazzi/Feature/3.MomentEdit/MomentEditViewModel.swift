//
//  MomentEditViewModel.swift
//  poporazzi
//
//  Created by 김민준 on 4/17/25.
//

import Foundation
import RxSwift
import RxCocoa

final class MomentEditViewModel: ViewModel {
    
    private let disposeBag = DisposeBag()
    
    struct Input {
        let viewDidLoad: Signal<Void>
        let titleTextChanged: Signal<String>
        let saveButtonTapped: Signal<Void>
    }
    
    struct Output {
        let record: Driver<Record>
        let titleText: Signal<String>
        let isSaveButtonEnabled: Driver<Bool>
        let dismiss: Signal<Void>
    }
    
    private let record = BehaviorRelay<Record>(value: .initialValue)
    private let titleText = BehaviorRelay<String>(value: "")
    private let isSaveButtonEnabled = BehaviorRelay<Bool>(value: true)
    private let dismiss = PublishRelay<Void>()
}

// MARK: - Transform

extension MomentEditViewModel {
    
    func transform(_ input: Input) -> Output {
        input.viewDidLoad
            .withUnretained(self)
            .map { owner, _ in owner.currentRecord() }
            .emit(to: record)
            .disposed(by: disposeBag)
        
        input.titleTextChanged
            .emit(to: titleText)
            .disposed(by: disposeBag)
        
        input.titleTextChanged
            .map { !$0.isEmpty }
            .emit(to: isSaveButtonEnabled)
            .disposed(by: disposeBag)
        
        input.saveButtonTapped
            .withUnretained(self)
            .emit { owner, _ in
                let currentTitle = owner.titleText.value
                let albumTitle = currentTitle.isEmpty ? UserDefaultsService.albumTitle : currentTitle
                UserDefaultsService.albumTitle = albumTitle
                owner.dismiss.accept(())
            }
            .disposed(by: disposeBag)
        
        return Output(
            record: record.asDriver(),
            titleText: titleText.asSignal(onErrorJustReturn: ""),
            isSaveButtonEnabled: isSaveButtonEnabled.asDriver(),
            dismiss: dismiss.asSignal()
        )
    }
}

// MARK: - Logic

extension MomentEditViewModel {
    
    /// UserDefault 값을 기반으로 Record를 반환합니다.
    private func currentRecord() -> Record {
        let albumTitle = UserDefaultsService.albumTitle
        let trackingStartDate = UserDefaultsService.trackingStartDate
        return Record(title: albumTitle, trackingStartDate: trackingStartDate)
    }
}
