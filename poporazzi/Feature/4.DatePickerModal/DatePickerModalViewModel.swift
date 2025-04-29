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
    
    private let state: State
    
    init(state: State) {
        self.state = state
    }
}

// MARK: - State & Action

extension DatePickerModalViewModel {
    
    struct State {
        let selectedDate: BehaviorRelay<Date>
    }
    
    struct Action {
        let viewDidLoad: Signal<Void>
        let datePickerChanged: Signal<Date>
    }
}

// MARK: - Transform

extension DatePickerModalViewModel {
    
    func transform(_ action: Action) -> State {
        action.datePickerChanged
            .emit(with: self) { owner, date in
                owner.state.selectedDate.accept(date)
            }
            .disposed(by: disposeBag)
        
        return state
    }
}
