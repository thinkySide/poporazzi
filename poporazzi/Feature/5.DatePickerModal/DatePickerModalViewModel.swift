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
        let viewWillAppear: Signal<Void>
        let datePickerChanged: Signal<Date>
        let confirmButtonTapped: Signal<Void>
    }
    
    struct Output {
        let modalState: BehaviorRelay<ModalState>
        let startDate: BehaviorRelay<Date>
        let endDate: BehaviorRelay<Date?>
        
        let setupSelectableStartDateRange = PublishRelay<Date?>()
        let setupSelectableEndDateRange = PublishRelay<Date>()
    }
    
    enum Navigation {
        case popFromStartDate(Date)
        case popFromEndDate(Date?)
    }
    
    enum ModalState {
        case startDate
        case endDate
    }
}

// MARK: - Transform

extension DatePickerModalViewModel {
    
    func transform(_ input: Input) -> Output {
        input.viewWillAppear
            .asObservable()
            .take(1)
            .bind(with: self) { owner, _ in
                switch owner.output.modalState.value {
                case .startDate:
                    let endDate = owner.output.endDate.value
                    owner.output.setupSelectableStartDateRange.accept(endDate)
                    
                case .endDate:
                    let startDate = owner.output.startDate.value
                    owner.output.setupSelectableEndDateRange.accept(startDate)
                }
            }
            .disposed(by: disposeBag)
        
        input.datePickerChanged
            .emit(with: self) { owner, date in
                switch owner.output.modalState.value {
                case .startDate: owner.output.startDate.accept(date)
                case .endDate: owner.output.endDate.accept(date)
                }
            }
            .disposed(by: disposeBag)
        
        input.confirmButtonTapped
            .emit(with: self) { owner, _ in
                switch owner.output.modalState.value {
                case .startDate:
                    owner.navigation.accept(.popFromStartDate(owner.output.startDate.value))
                    
                case .endDate:
                    owner.navigation.accept(.popFromEndDate(owner.output.endDate.value))
                }
                
                HapticManager.impact(style: .soft)
            }
            .disposed(by: disposeBag)
        
        return output
    }
}
