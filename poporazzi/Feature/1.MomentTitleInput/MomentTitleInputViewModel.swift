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
    
    private let disposeBag = DisposeBag()
}

// MARK: - Input & Output

extension MomentTitleInputViewModel {
    
    struct Input {
        let titleTextFieldDidChange: Observable<String>
        let actionButtonTapped: Observable<Void>
    }
    
    struct Output {
        let titleTextFieldText: PublishRelay<String> = .init()
        let actionButtonIsEnabled: PublishRelay<Bool> = .init()
        let navigateToRecordView: PublishRelay<String> = .init()
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
            .do {
                UserDefaultsService.isTracking = true
                UserDefaultsService.albumTitle = $0
                UserDefaultsService.trackingStartDate = .now
            }
            .bind(to: output.navigateToRecordView)
            .disposed(by: disposeBag)
        
        return output
    }
}
