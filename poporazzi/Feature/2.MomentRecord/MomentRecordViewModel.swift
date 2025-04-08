//
//  MomentRecordViewModel.swift
//  poporazzi
//
//  Created by 김민준 on 4/5/25.
//

import Foundation
import RxSwift
import RxCocoa
import Photos

final class MomentRecordViewModel: ViewModel {
    
    private let photoKitService = PhotoKitService()
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
            .flatMap({ [weak self] _ in
                let trackingStartDate = UserDefaultsService.trackingStartDate
                let fetchResult = self?.photoKitService.fetchAssetResult(
                    mediaFetchType: .all,
                    date: trackingStartDate,
                    ascending: true
                )
                return self?.photoKitService.fetchPhotos(fetchResult) ?? .empty()
            })
            .bind(to: output.photoListResponse)
            .disposed(by: disposeBag)
        
        return output
    }
}
