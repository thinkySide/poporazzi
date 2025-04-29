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
    func transform(_ action: Action) -> State {
        State()
    }
    
    
    private let disposeBag = DisposeBag()
    
    struct Action {
        let viewDidLoad: Signal<Void>
        let datePickerChanged: Signal<Date>
    }
    
    struct State {
        
    }
    
    struct Effect {
        let selectedDate: Driver<Date>
    }
    
    private let selectedDate = BehaviorRelay<Date>(value: .now)
}

// MARK: - Transform

extension DatePickerModalViewModel {
    
    func transform(_ input: Action) -> (State, Effect) {
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
        
        return (State(), Effect(
            selectedDate: selectedDate.asDriver()
        ))
    }
}
