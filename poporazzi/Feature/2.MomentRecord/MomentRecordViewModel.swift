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
    
    private let photoRepository: PhotoRepository
    private let disposeBag = DisposeBag()
    
    init(photoRepository: PhotoRepository) {
        self.photoRepository = photoRepository
    }
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
            .flatMap({ [weak self] _ in
                let trackingStartDate = UserDefaultsService.trackingStartDate
                return self?.photoRepository.fetchPhotos(from: trackingStartDate) ?? .empty()
            })
            .bind(to: output.photoListResponse)
            .disposed(by: disposeBag)
        
        return output
    }
}
