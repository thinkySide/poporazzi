//
//  AuthRequestModalViewModel.swift
//  poporazzi
//
//  Created by 김민준 on 5/21/25.
//

import Foundation
import RxSwift
import RxCocoa

final class AuthRequestModalViewModel: ViewModel {
    
    @Dependency(\.photoKitService) private var photoKitService
    
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

extension AuthRequestModalViewModel {
    
    struct Input {
        
    }
    
    struct Output {
        
    }
    
    enum Navigation {
        
    }
}

// MARK: - Transform

extension AuthRequestModalViewModel {
    
    func transform(_ input: Input) -> Output {
        
        return output
    }
}
