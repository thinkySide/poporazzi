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
    
    private let state: State
    
    let navigation = PublishRelay<Navigation>()
    let delegate = PublishRelay<Delegate>()
    
    init(state: State) {
        self.state = state
    }
}

// MARK: - State & Action

extension MomentEditViewModel {
    
    struct State {
        let record: BehaviorRelay<Record>
        let titleText: BehaviorRelay<String>
        let startDate: BehaviorRelay<Date>
        let isSaveButtonEnabled = BehaviorRelay<Bool>(value: true)
    }
    
    struct Action {
        let viewDidLoad: Signal<Void>
        let titleTextChanged: Signal<String>
        let startDatePickerTapped: Signal<Void>
        let backButtonTapped: Signal<Void>
        let saveButtonTapped: Signal<Void>
    }
    
    enum Navigation {
        case presentStartDatePicker(Date)
        case dismiss(Record)
    }
    
    enum Delegate {
        case startDateDidChanged(Date)
    }
}

// MARK: - Transform

extension MomentEditViewModel {
    
    func transform(_ action: Action) -> State {
        action.titleTextChanged
            .emit(to: state.titleText)
            .disposed(by: disposeBag)
        
        action.titleTextChanged
            .map { !$0.isEmpty }
            .emit(to: state.isSaveButtonEnabled)
            .disposed(by: disposeBag)
        
        action.startDatePickerTapped
            .emit(with: self) { owner, _ in
                let startDate = owner.state.record.value.trackingStartDate
                owner.navigation.accept(.presentStartDatePicker(startDate))
            }
            .disposed(by: disposeBag)
        
        action.backButtonTapped
            .emit(with: self) { owner, _ in
                owner.navigation.accept(.dismiss(owner.state.record.value))
            }
            .disposed(by: disposeBag)
        
        action.saveButtonTapped
            .emit(with: self) { owner, _ in
                let currentTitle = owner.state.titleText.value
                let albumTitle = currentTitle.isEmpty ? UserDefaultsService.albumTitle : currentTitle
                let record = (Record(title: albumTitle, trackingStartDate: owner.state.startDate.value))
                owner.navigation.accept(.dismiss(record))
                UserDefaultsService.record = record
            }
            .disposed(by: disposeBag)
        
        delegate
            .bind(with: self) { owner, delegate in
                switch delegate {
                case .startDateDidChanged(let date):
                    owner.state.startDate.accept(date)
                }
            }
            .disposed(by: disposeBag)
        
        return state
    }
}
