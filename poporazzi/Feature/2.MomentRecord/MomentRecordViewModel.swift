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
        let viewDidLoad: Observable<Void>
    }
    
    struct Output {
        let photoListResponse: BehaviorRelay<[Photo]> = .init(value: [])
    }
    
    func transform(_ input: Input) -> Output {
        let output = Output()
        
        input.viewDidLoad
            .map { self.dummy() }
            .bind(to: output.photoListResponse)
            .disposed(by: disposeBag)
        
        return output
    }
    
    func dummy() -> [Photo] {
        Array(repeating: Photo(imageURLString: "더미이미지"), count: 17)
    }
}
