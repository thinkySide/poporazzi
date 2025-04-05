//
//  MomentTitleInputViewModel.swift
//  poporazzi
//
//  Created by 김민준 on 4/5/25.
//

import Foundation
import RxSwift
import RxCocoa

final class MomentTitleInputViewModel: ViewModel {
    var disposeBag = DisposeBag()
}

// MARK: - Input & Output

extension MomentTitleInputViewModel {
    
    struct Input {
        let titleTextFieldDidChange: Observable<String>
        let actionButtonTapped: Observable<Void>
    }
    
    struct Output {
        let titleTextFieldText = PublishRelay<String>()
        let actionButtonIsEnabled = PublishRelay<Bool>()
        let navigateToRecordView = PublishRelay<String>()
    }
    
    func transform(_ input: Input) -> Output {
        let output = Output()
        
        input.titleTextFieldDidChange
            .bind(to: output.titleTextFieldText)
            .disposed(by: disposeBag)
        
        input.titleTextFieldDidChange
            .map { !$0.isEmpty }
            .bind(to: output.actionButtonIsEnabled)
            .disposed(by: disposeBag)
        
        input.actionButtonTapped
            .withLatestFrom(output.titleTextFieldText)
            .bind(to: output.navigateToRecordView)
            .disposed(by: disposeBag)
        
        return output
    }
}
