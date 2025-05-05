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
    }
    
    struct Output {
        
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
        
        return output
    }
}
