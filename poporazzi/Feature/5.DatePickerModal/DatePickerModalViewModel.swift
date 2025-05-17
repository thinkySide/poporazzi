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
//        switch output.modalState.value {
//        case let .startDate(date): output.selectedDate.accept(date)
//        case let .endDate(date): output.selectedDate.accept(date)
//        }
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
        let modalState: BehaviorRelay<ModalState>
        let startDate: BehaviorRelay<Date>
        let endDate: BehaviorRelay<Date?>
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
