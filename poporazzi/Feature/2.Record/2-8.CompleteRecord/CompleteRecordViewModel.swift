//
//  CompleteRecordViewModel.swift
//  poporazzi
//
//  Created by 김민준 on 6/17/25.
//

import UIKit
import RxSwift
import RxCocoa

final class CompleteRecordViewModel: ViewModel {
    
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

extension CompleteRecordViewModel {
    
    struct Input {
        
    }
    
    struct Output {
        let record: BehaviorRelay<Record>
        let mediaList: BehaviorRelay<[Media]>
        let randomImageList: BehaviorRelay<[UIImage]>
    }
    
    enum Navigation {
        
    }
}

// MARK: - Transform

extension CompleteRecordViewModel {
    
    func transform(_ input: Input) -> Output {
        
        return output
    }
}
