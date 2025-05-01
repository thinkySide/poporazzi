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

extension DatePickerModalViewModel {
    
    struct Input {
        let viewDidLoad: Signal<Void>
        let datePickerChanged: Signal<Date>
        let confirmButtonTapped: Signal<Void>
    }
    
    struct Output {
        let selectedDate: BehaviorRelay<Date>
    }
    
    enum Navigation {
        case pop(Date)
    }
}

// MARK: - Transform

extension DatePickerModalViewModel {
    
    func transform(_ input: Input) -> Output {
        input.datePickerChanged
            .emit(with: self) { owner, date in
                owner.output.selectedDate.accept(date)
            }
            .disposed(by: disposeBag)
        
        input.confirmButtonTapped
            .emit(with: self) { owner, _ in
                owner.navigation.accept(.pop(owner.output.selectedDate.value))
            }
            .disposed(by: disposeBag)
        
        return output
    }
}
