//
//  ExcludeRecordViewModel.swift
//  poporazzi
//
//  Created by 김민준 on 5/5/25.
//

import Foundation
import RxSwift
import RxCocoa

final class ExcludeRecordViewModel: ViewModel {
    
    let disposeBag = DisposeBag()
    
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

extension ExcludeRecordViewModel {
    
    struct Input {
        let backButtonTapped: Signal<Void>
        let selectButtonTapped: Signal<Void>
        let selectCancelButtonTapped: Signal<Void>
    }
    
    struct Output {
        let selectedRecordCells = BehaviorRelay<[Media]>(value: [])
        let switchSelectMode = PublishRelay<Bool>()
    }
    
    enum Navigation {
        case dismiss
    }
}

// MARK: - Transform

extension ExcludeRecordViewModel {
    
    func transform(_ input: Input) -> Output {
        input.backButtonTapped
            .emit(with: self) { owner, _ in
                owner.navigation.accept(.dismiss)
            }
            .disposed(by: disposeBag)
        
        input.selectButtonTapped
            .map { true }
            .emit(to: output.switchSelectMode)
            .disposed(by: disposeBag)
        
        input.selectCancelButtonTapped
            .emit(with: self) { owner, _ in
                owner.output.selectedRecordCells.accept([])
                owner.output.switchSelectMode.accept(false)
            }
            .disposed(by: disposeBag)
        
        return output
    }
}
