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
    private let output: Output
    
    let navigation = PublishRelay<Navigation>()
    
    init(output: Output) {
        self.output = output
    }
}

// MARK: - Input & Output

extension TitleInputViewModel {
    
    struct Input {
        let titleTextChanged: Signal<String>
        let startButtonTapped: Signal<Void>
    }
    
    struct Output {
        let titleText = BehaviorRelay<String>(value: "")
        let isStartButtonEnabled = BehaviorRelay<Bool>(value: false)
    }
    
    enum Navigation {
        case pushRecord(Record)
    }
}

// MARK: - Transform

extension TitleInputViewModel {
    
    func transform(_ input: Input) -> Output {
        input.titleTextChanged
            .emit(to: output.titleText)
            .disposed(by: disposeBag)
        
        input.titleTextChanged
            .map { !$0.isEmpty }
            .emit(to: output.isStartButtonEnabled)
            .disposed(by: disposeBag)
        
        input.startButtonTapped
            .emit(with: self) { owner, _ in
                let record = Record(title: owner.output.titleText.value, trackingStartDate: .now)
                owner.navigation.accept(.pushRecord(record))
                UserDefaultsService.record = record
                UserDefaultsService.isTracking = true
            }
            .disposed(by: disposeBag)
        
        return output
    }
}
