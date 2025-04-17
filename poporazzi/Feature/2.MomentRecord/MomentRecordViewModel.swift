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
    
    private let disposeBag = DisposeBag()
    private let photoKitService = PhotoKitService()
    private var fetchResult: PHFetchResult<PHAsset>?
    
    struct Input {
        let viewDidLoad: Signal<Void>
        let viewBecomeActive: Signal<Notification>
        let viewDidRefresh: Signal<Void>
        let seemoreButtonTapped: Signal<Void>
        let finishButtonTapped: Signal<Void>
        let cameraFloatingButtonTapped: Signal<Void>
    }
    
    struct Output {
        let record: Driver<Record>
        let photoList: Driver<[Photo]>
        let finishAlertPresented: Signal<Alert>
        let saveCompleteAlertPresented: Signal<Alert>
        let navigateToHome: Signal<Void>
    }
    
    struct AlertAction {
        let save = PublishRelay<Void>()
        let navigateToHome = PublishRelay<Void>()
    }
    
    private let alert = AlertAction()
    private let record = BehaviorRelay<Record>(value: .initialValue)
    private let photoList = BehaviorRelay<[Photo]>(value: [])
    private let finishAlertPresented = PublishRelay<Alert>()
    private let saveCompleteAlertPresented = PublishRelay<Alert>()
    private let navigateToHome = PublishRelay<Void>()
}

// MARK: - Input & Output

extension MomentRecordViewModel {
    
    func transform(_ input: Input) -> Output {
        let updateRecord = Signal.merge(
            input.viewDidLoad,
            input.viewDidRefresh,
            input.viewBecomeActive.map { _ in }
        )
        
        updateRecord
            .withUnretained(self)
            .map { owner, _ in owner.currentRecord() }
            .emit(to: record)
            .disposed(by: disposeBag)
        
        updateRecord
            .asObservable()
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .userInteractive))
            .withUnretained(self)
            .flatMap { owner, _ in owner.fetchCurrentPhotos() }
            .bind(to: photoList)
            .disposed(by: disposeBag)
        
        input.seemoreButtonTapped
            .emit(with: self) { owner, _ in
                print("seemoreButtonTapped")
            }
            .disposed(by: disposeBag)
        
        input.cameraFloatingButtonTapped
            .emit(with: self) { owner, _ in
                print("cameraFloatingButtonTapped")
            }
            .disposed(by: disposeBag)
        
        input.finishButtonTapped
            .emit(with: self) { owner, _ in
                owner.finishAlertPresented.accept(owner.finishAlert)
            }
            .disposed(by: disposeBag)
        
        alert.save
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .userInteractive))
            .bind(with: self) { owner, _ in
                do {
                    try owner.saveToAlbums()
                    owner.saveCompleteAlertPresented.accept(owner.saveAlert)
                } catch {
                    print(error)
                }
            }
            .disposed(by: disposeBag)
        
        alert.navigateToHome
            .do { _ in UserDefaultsService.isTracking = false }
            .bind(to: navigateToHome)
            .disposed(by: disposeBag)
        
        return Output(
            record: record.asDriver(),
            photoList: photoList.asDriver(),
            finishAlertPresented: finishAlertPresented.asSignal(),
            saveCompleteAlertPresented: saveCompleteAlertPresented.asSignal(),
            navigateToHome: navigateToHome.asSignal()
        )
    }
}

// MARK: - Logic

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
    
    /// 앨범에 저장합니다.
    private func saveToAlbums() throws {
        let title = UserDefaultsService.albumTitle
        try photoKitService.saveAlbum(title: title, assets: fetchResult)
    }
}

// MARK: - Alert

extension MomentRecordViewModel {
    
    /// 기록 종료 Alert
    private var finishAlert: Alert {
        let title = UserDefaultsService.albumTitle
        let totalCount = photoList.value.count
        return Alert(
            title: "기록을 종료할까요?",
            message: "총 \(totalCount)장의 '\(title)' 기록 종료 후 앨범에 저장돼요",
            eventButton: .init(title: "종료", action: alert.save),
            cancelButton: .init(title: "취소")
        )
    }
    
    /// 앨범 저장 Alert
    private var saveAlert: Alert {
        let title = UserDefaultsService.albumTitle
        return Alert(
            title: "기록이 종료되었습니다!",
            message: "'\(title)' 앨범을 확인해보세요!",
            eventButton: .init(title: "홈으로 돌아가기", action: alert.navigateToHome)
        )
    }
}
