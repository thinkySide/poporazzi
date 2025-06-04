//
//  OnboardingViewModel.swift
//  poporazzi
//
//  Created by 김민준 on 6/4/25.
//

import Foundation
import RxSwift
import RxCocoa

final class OnboardingViewModel: ViewModel {
    
    private let output: Output
    
    let disposeBag = DisposeBag()
    let navigation = PublishRelay<Navigation>()
    
    init(output: Output) {
        self.output = output
    }
    
    deinit {
        Log.print(#file, .deinit)
    }
}

// MARK: - Input & Output

extension OnboardingViewModel {
    
    struct Input {
        
    }
    
    struct Output {
        
    }
    
    enum Navigation {
        
    }
}

// MARK: - Transform

extension OnboardingViewModel {
    
    func transform(_ input: Input) -> Output {
        
        return output
    }
}
