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
    private var fetchResult: PHFetchResult<PHAsset>?
}

// MARK: - Input & Output

extension MomentRecordViewModel {
    
    struct Input {
        let viewDidLoad: Observable<Void>
        let finishButtonTapped: Observable<Void>
    }
    
    struct Output {
        let photoListResponse: BehaviorRelay<[Photo]> = .init(value: [])
        let saveToAlbum: PublishRelay<Void> = .init()
    }
    
    func transform(_ input: Input) -> Output {
        let output = Output()
        
        input.viewDidLoad
            .flatMap({ [weak self] _ in
                let trackingStartDate = UserDefaultsService.trackingStartDate
                self?.fetchResult = self?.photoKitService.fetchAssetResult(
                    mediaFetchType: .all,
                    date: trackingStartDate,
                    ascending: true
                )
                return self?.photoKitService.fetchPhotos(self?.fetchResult) ?? .empty()
            })
            .bind(to: output.photoListResponse)
            .disposed(by: disposeBag)
        
        input.finishButtonTapped
            .do(onNext: { [weak self] _ in
                let title = UserDefaultsService.albumTitle
                try self?.photoKitService.saveAlbum(title: title, assets: self?.fetchResult)
            })
            .bind(to: output.saveToAlbum)
            .disposed(by: disposeBag)
        
        return output
    }
}
