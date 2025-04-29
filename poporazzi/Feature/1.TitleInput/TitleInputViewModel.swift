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
    
    let state: State
    let navigation = PublishRelay<Navigation>()
    
    init(state: State) {
        self.state = state
    }
}

// MARK: - State / Action / Effect

extension TitleInputViewModel {
    
    struct State {
        let titleText = BehaviorRelay<String>(value: "")
        let isStartButtonEnabled = BehaviorRelay<Bool>(value: false)
    }
    
    struct Action {
        let titleTextChanged: Signal<String>
        let startButtonTapped: Signal<Void>
    }
    
    enum Navigation {
        case pushRecord(Record)
    }
}

// MARK: - Transform

extension TitleInputViewModel {
    
    func transform(_ action: Action) -> State {
        action.titleTextChanged
            .emit(to: state.titleText)
            .disposed(by: disposeBag)
        
        action.titleTextChanged
            .map { !$0.isEmpty }
            .emit(to: state.isStartButtonEnabled)
            .disposed(by: disposeBag)
        
        action.startButtonTapped
            .emit(with: self) { owner, _ in
                let record = Record(title: owner.state.titleText.value, trackingStartDate: .now)
                owner.navigation.accept(.pushRecord(record))
                UserDefaultsService.record = record
                UserDefaultsService.isTracking = true
            }
            .disposed(by: disposeBag)
        
        return state
    }
}
