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
        let viewDidLoad: Signal<Void>
        let datePickerChanged: Signal<Date>
    }
    
    struct Output {
        let selectedDate: Driver<Date>
    }
    
    private let selectedDate = BehaviorRelay<Date>(value: .now)
}

// MARK: - Transform

extension DatePickerModalViewModel {
    
    func transform(_ input: Input) -> Output {
        input.viewDidLoad
            .emit(with: self) { owner, _ in
                let startDate = UserDefaultsService.trackingStartDate
                owner.selectedDate.accept(startDate)
            }
            .disposed(by: disposeBag)
        
        input.datePickerChanged
            .emit(with: self) { owner, date in
                owner.selectedDate.accept(date)
            }
            .disposed(by: disposeBag)
        
        return Output(
            selectedDate: selectedDate.asDriver()
        )
    }
}
