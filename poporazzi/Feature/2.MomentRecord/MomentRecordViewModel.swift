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
    
    let output = Output()
}

// MARK: - Input & Output

extension MomentRecordViewModel {
    
    struct Input {
        let viewDidLoad: Observable<Void>
        let viewBecomeActive: Observable<Notification>
        let refresh: Observable<Void>
        let finishButtonTapped: Observable<Void>
        let saveToAlbumButtonTapped: PublishRelay<Void>
        let backToHomeButtonTapped: PublishRelay<Void>
    }
    
    struct Output {
        let currentRecord: BehaviorRelay<Record> = .init(value: .initialValue)
        let photoList: BehaviorRelay<[Photo]> = .init(value: [])
        let finishAlertPresented: PublishRelay<Void> = .init()
        let saveToAlbum: PublishRelay<Void> = .init()
        let backToHome: PublishRelay<Void> = .init()
    }
    
    func transform(_ input: Input) -> Output {
        let updateRecord = Observable.merge(
            input.viewDidLoad,
            input.refresh,
            input.viewBecomeActive.map { _ in }
        )
        
        updateRecord
            .withUnretained(self)
            .map { owner, _ in owner.currentRecord() }
            .bind(to: output.currentRecord)
            .disposed(by: disposeBag)
        
        updateRecord
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .default))
            .withUnretained(self)
            .flatMap { owner, _ in owner.fetchCurrentPhotos() }
            .bind(to: output.photoList)
            .disposed(by: disposeBag)
        
        input.finishButtonTapped
            .bind(to: output.finishAlertPresented)
            .disposed(by: disposeBag)
        
        input.saveToAlbumButtonTapped
            .do(onNext: { [weak self] _ in
                let title = UserDefaultsService.albumTitle
                try self?.photoKitService.saveAlbum(title: title, assets: self?.fetchResult)
            })
            .bind(to: output.saveToAlbum)
            .disposed(by: disposeBag)
        
        input.backToHomeButtonTapped
            .bind(to: output.backToHome)
            .disposed(by: disposeBag)
        
        return output
    }
}

// MARK: - Helper

extension MomentRecordViewModel {
    
    /// UserDefault 값을 기반으로 Record를 반환합니다.
    private func currentRecord() -> Record {
        let albumTitle = UserDefaultsService.albumTitle
        let trackingStartDate = UserDefaultsService.trackingStartDate
        return Record(title: albumTitle, trackingStartDate: trackingStartDate)
    }
    
    /// 현재 사진 리스트를 반환합니다.
    private func fetchCurrentPhotos() -> Observable<[Photo]> {
        let trackingStartDate = UserDefaultsService.trackingStartDate
        fetchResult = photoKitService.fetchAssetResult(
            mediaFetchType: .all,
            date: trackingStartDate,
            ascending: true
        )
        return photoKitService.fetchPhotos(fetchResult)
    }
}
