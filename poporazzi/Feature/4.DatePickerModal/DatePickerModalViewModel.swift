//
//  DatePickerModalViewModel.swift
//  poporazzi
//
//  Created by 김민준 on 4/18/25.
//

import Foundation
import RxSwift
import RxCocoa

final class DatePickerModalViewModel: ViewModel {
    
    private let disposeBag = DisposeBag()
    
    struct Input {
        let datePickerChanged: Signal<Date>
        let confirmButtonTapped: Signal<Void>
    }
    
    struct Output {
        let selectedDate: Driver<Date>
        let confirm: Signal<Date>
    }
    
    let selectedDate = BehaviorRelay<Date>(value: .now)
    let confirm = PublishRelay<Date>()
}

// MARK: - Transform

extension DatePickerModalViewModel {
    
    func transform(_ input: Input) -> Output {
        input.datePickerChanged
            .emit(with: self) { owner, date in
                owner.selectedDate.accept(date)
            }
            .disposed(by: disposeBag)
        
        input.confirmButtonTapped
            .withUnretained(self)
            .map { owner, _ in owner.selectedDate.value }
            .emit(to: confirm)
            .disposed(by: disposeBag)
        
        return Output(
            selectedDate: selectedDate.asDriver(),
            confirm: confirm.asSignal()
        )
    }
}
