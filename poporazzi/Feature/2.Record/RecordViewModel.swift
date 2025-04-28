//
//  RecordViewModel.swift
//  poporazzi
//
//  Created by 김민준 on 4/5/25.
//

import UIKit
import RxSwift
import RxCocoa
import Photos

final class RecordViewModel: ViewModel {
    
    private let disposeBag = DisposeBag()
    private let photoKitService = PhotoKitService()
    private var fetchResult: PHFetchResult<PHAsset>?
    
    struct Input {
        let viewDidLoad: Signal<Void>
        let viewBecomeActive: Signal<Notification>
        let viewDidRefresh: Signal<Void>
        let seemoreButtonTapped: Signal<Void>
        let finishButtonTapped: Signal<Void>
    }
    
    struct Output {
        let record: Driver<Record>
        let mediaList: Driver<[Media]>
        let seemoreMenuPresented: Signal<UIMenu>
        let finishAlertPresented: Signal<Alert>
        let saveCompleteAlertPresented: Signal<Alert>
        let navigateToHome: Signal<Void>
        let navigateToEdit: Signal<Void>
    }
    
    struct AlertAction {
        let save = PublishRelay<Void>()
        let navigateToHome = PublishRelay<Void>()
    }
    
    struct MenuAction {
        let edit = PublishRelay<Void>()
    }
    
    private let alertAction = AlertAction()
    private let menuAction = MenuAction()
    
    private let record = BehaviorRelay<Record>(value: .initialValue)
    private let mediaList = BehaviorRelay<[Media]>(value: [])
    private let seemoreMenuPresented = PublishRelay<UIMenu>()
    private let finishAlertPresented = PublishRelay<Alert>()
    private let saveCompleteAlertPresented = PublishRelay<Alert>()
    private let navigateToHome = PublishRelay<Void>()
    private let navigateToEdit = PublishRelay<Void>()
}

// MARK: - Input & Output

extension RecordViewModel {
    
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
            .bind(to: mediaList)
            .disposed(by: disposeBag)
        
        input.seemoreButtonTapped
            .withUnretained(self)
            .map { owner, _ in owner.seemoreMenu }
            .emit(to: seemoreMenuPresented)
            .disposed(by: disposeBag)
        
        input.finishButtonTapped
            .emit(with: self) { owner, _ in
                owner.finishAlertPresented.accept(owner.finishAlert)
            }
            .disposed(by: disposeBag)
        
        alertAction.save
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
        
        alertAction.navigateToHome
            .do { _ in UserDefaultsService.isTracking = false }
            .bind(to: navigateToHome)
            .disposed(by: disposeBag)
        
        menuAction.edit
            .bind(to: navigateToEdit)
            .disposed(by: disposeBag)
        
        return Output(
            record: record.asDriver(),
            mediaList: mediaList.asDriver(),
            seemoreMenuPresented: seemoreMenuPresented.asSignal(),
            finishAlertPresented: finishAlertPresented.asSignal(),
            saveCompleteAlertPresented: saveCompleteAlertPresented.asSignal(),
            navigateToHome: navigateToHome.asSignal(),
            navigateToEdit: navigateToEdit.asSignal()
        )
    }
}

// MARK: - Album Logic

extension RecordViewModel {
    
    /// UserDefault 값을 기반으로 Record를 반환합니다.
    private func currentRecord() -> Record {
        let albumTitle = UserDefaultsService.albumTitle
        let trackingStartDate = UserDefaultsService.trackingStartDate
        return Record(title: albumTitle, trackingStartDate: trackingStartDate)
    }
    
    /// 현재 사진 리스트를 반환합니다.
    private func fetchCurrentPhotos() -> Observable<[Media]> {
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

extension RecordViewModel {
    
    /// 기록 종료 Alert
    private var finishAlert: Alert {
        let title = UserDefaultsService.albumTitle
        let totalCount = mediaList.value.count
        return Alert(
            title: "기록을 종료할까요?",
            message: "총 \(totalCount)장의 '\(title)' 기록 종료 후 앨범에 저장돼요",
            eventButton: .init(title: "종료", action: alertAction.save),
            cancelButton: .init(title: "취소")
        )
    }
    
    /// 앨범 저장 Alert
    private var saveAlert: Alert {
        let title = UserDefaultsService.albumTitle
        return Alert(
            title: "기록이 종료되었습니다!",
            message: "'\(title)' 앨범을 확인해보세요!",
            eventButton: .init(title: "홈으로 돌아가기", action: alertAction.navigateToHome)
        )
    }
}

// MARK: - UIAction

extension RecordViewModel {
    
    /// 더보기 메뉴를 반환합니다.
    private var seemoreMenu: UIMenu {
        let editImage = UIImage(systemName: SFSymbol.edit.rawValue)
        let editAction = UIAction(title: "기록 수정", image: editImage) { [weak self] _ in
            self?.menuAction.edit.accept(())
        }
        return UIMenu(children: [editAction])
    }
}
