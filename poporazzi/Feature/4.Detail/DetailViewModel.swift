//
//  DetailViewModel.swift
//  poporazzi
//
//  Created by 김민준 on 5/26/25.
//

import Foundation
import RxSwift
import RxCocoa

final class DetailViewModel: ViewModel {
    
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

extension DetailViewModel {
    
    struct Input {
        
    }
    
    struct Output {
        
    }
    
    enum Navigation {
        
    }
}

// MARK: - Transform

extension DetailViewModel {
    
    func transform(_ input: Input) -> Output {
        return output
    }
}
