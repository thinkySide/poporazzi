//
//  SettingsViewModel.swift
//  poporazzi
//
//  Created by 김민준 on 5/23/25.
//

import Foundation
import RxSwift
import RxCocoa

final class SettingsViewModel: ViewModel {
    
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

extension SettingsViewModel {
    
    struct Input {
        let writeAppStoreReviviewButton: Signal<Void>
    }
    
    struct Output {
        
    }
    
    enum Navigation {
        
    }
}

// MARK: - Transform

extension SettingsViewModel {
    
    func transform(_ input: Input) -> Output {
        input.writeAppStoreReviviewButton
            .emit(with: self) { owner, _ in
                print("writeAppStoreReviviewButton")
            }
            .disposed(by: disposeBag)
        
        return output
    }
}
