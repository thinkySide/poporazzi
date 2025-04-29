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
    func transform(_ action: Action) -> State {
        return State()
    }
    
    
    private let disposeBag = DisposeBag()
    private let output: Effect
    
    let navigation = Navigation()
    
    init(record: Record) {
        self.output = Effect(
            record: .init(value: record),
            titleText: .init(value: record.title)
        )
    }
    
    struct Action {
        let viewDidLoad: Signal<Void>
        let titleTextChanged: Signal<String>
        let saveButtonTapped: Signal<Void>
    }
    
    struct State {
        
    }
    
    struct Effect {
        let record: BehaviorRelay<Record>
        let titleText: BehaviorRelay<String>
        let isSaveButtonEnabled = BehaviorRelay<Bool>(value: true)
    }
    
    struct Navigation {
        let dismiss = PublishRelay<Record>()
    }
}

// MARK: - Transform

extension MomentEditViewModel {
    
    func transform(_ input: Action) -> (State, Effect) {
        input.viewDidLoad
            .withUnretained(self)
            .map { owner, _ in owner.output.record.value }
            .emit(to: output.record)
            .disposed(by: disposeBag)
        
        input.titleTextChanged
            .emit(to: output.titleText)
            .disposed(by: disposeBag)
        
        input.titleTextChanged
            .map { !$0.isEmpty }
            .emit(to: output.isSaveButtonEnabled)
            .disposed(by: disposeBag)
        
        input.saveButtonTapped
            .withUnretained(self)
            .emit { owner, _ in
                let currentTitle = owner.output.titleText.value
                let albumTitle = currentTitle.isEmpty ? UserDefaultsService.albumTitle : currentTitle
                let record = (Record(title: albumTitle, trackingStartDate: .now))
                owner.navigation.dismiss.accept(record)
                UserDefaultsService.record = record
            }
            .disposed(by: disposeBag)
        
        return (State(), output)
    }
}
