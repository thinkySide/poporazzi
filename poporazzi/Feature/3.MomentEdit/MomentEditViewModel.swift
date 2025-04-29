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
    
    let navigation = Navigation()
    
    init(state: State) {
        self.state = state
    }
}

// MARK: - State & Action

extension MomentEditViewModel {
    
    struct State {
        let record: BehaviorRelay<Record>
        let titleText: BehaviorRelay<String>
        let isSaveButtonEnabled = BehaviorRelay<Bool>(value: true)
    }
    
    struct Action {
        let viewDidLoad: Signal<Void>
        let titleTextChanged: Signal<String>
        let saveButtonTapped: Signal<Void>
    }
    
    struct Navigation {
        let dismiss = PublishRelay<Record>()
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
        
        action.saveButtonTapped
            .withUnretained(self)
            .emit { owner, _ in
                let currentTitle = owner.state.titleText.value
                let albumTitle = currentTitle.isEmpty ? UserDefaultsService.albumTitle : currentTitle
                let record = (Record(title: albumTitle, trackingStartDate: .now))
                owner.navigation.dismiss.accept(record)
                UserDefaultsService.record = record
            }
            .disposed(by: disposeBag)
        
        return state
    }
}
