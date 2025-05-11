//
//  FinishModalViewModel.swift
//  poporazzi
//
//  Created by 김민준 on 5/11/25.
//

import Foundation
import RxSwift
import RxCocoa

final class FinishModalViewModel: ViewModel {
    
    private let disposeBag = DisposeBag()
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

extension FinishModalViewModel {
    
    struct Input {
        let saveAsSingleRadioButtonTapped: Signal<Void>
        let saveByDayRadioButtonTapped: Signal<Void>
        let cancelButtonTapped: Signal<Void>
    }
    
    struct Output {
        let saveOption = BehaviorRelay<SaveOption>(value: .none)
    }
    
    enum Navigation {
        case dismiss(isSaved: Bool)
    }
    
    enum SaveOption {
        case none
        case saveAsSingle
        case saveByDay
    }
}

// MARK: - Transform

extension FinishModalViewModel {
    
    func transform(_ input: Input) -> Output {
        input.cancelButtonTapped
            .emit(with: self) { owner, _ in
                owner.navigation.accept(.dismiss(isSaved: false))
            }
            .disposed(by: disposeBag)
        
        input.saveAsSingleRadioButtonTapped
            .map { SaveOption.saveAsSingle }
            .emit(to: output.saveOption)
            .disposed(by: disposeBag)
        
        input.saveByDayRadioButtonTapped
            .map { SaveOption.saveByDay }
            .emit(to: output.saveOption)
            .disposed(by: disposeBag)
        
        return output
    }
}
