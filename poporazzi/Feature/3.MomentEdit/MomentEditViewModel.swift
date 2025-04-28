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
    private let output: Output
    
    let navigation = Navigation()
    
    init(record: Record) {
        self.output = Output(
            record: .init(value: record),
            titleText: .init(value: record.title)
        )
    }
    
    struct Input {
        let viewDidLoad: Signal<Void>
        let titleTextChanged: Signal<String>
        let saveButtonTapped: Signal<Void>
    }
    
    struct Output {
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
    
    func transform(_ input: Input) -> Output {
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
        
        return output
    }
}
