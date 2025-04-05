//
//  MomentRecordViewModel.swift
//  poporazzi
//
//  Created by 김민준 on 4/5/25.
//

import Foundation
import RxSwift
import RxCocoa

final class MomentRecordViewModel: ViewModel {
    
    private let disposeBag = DisposeBag()
}

// MARK: - Input & Output

extension MomentRecordViewModel {
    
    struct Input {
        
    }
    
    struct Output {
        
    }
    
    func transform(_ input: Input) -> Output {
        let output = Output()
        return output
    }
}
