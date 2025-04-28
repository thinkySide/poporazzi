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
    
    private let photoKitService = PhotoKitService()
    private var fetchResult: PHFetchResult<PHAsset>?
    
    private let disposeBag = DisposeBag()
    private let output: Output
    
    private let alertAction = AlertAction()
    private let menuAction = MenuAction()
    
    let navigation = Navigation()
    let delegate = Delegate()
    
    init(record: Record) {
        self.output = Output(record: .init(value: record))
    }
    
    struct Input {
        let viewDidLoad: Signal<Void>
        let viewBecomeActive: Signal<Notification>
        let refresh: Signal<Void>
        let seemoreButtonTapped: Signal<Void>
        let finishButtonTapped: Signal<Void>
    }
    
    struct Output {
        let record: BehaviorRelay<Record>
        let mediaList = BehaviorRelay<[Media]>(value: [])
        let seemoreMenuPresented = PublishRelay<UIMenu>()
        let finishAlertPresented = PublishRelay<Alert>()
        let saveCompleteAlertPresented = PublishRelay<Alert>()
    }
    
    struct AlertAction {
        let save = PublishRelay<Void>()
        let navigateToHome = PublishRelay<Void>()
    }
    
    struct MenuAction {
        let edit = PublishRelay<Void>()
    }
    
    struct Navigation {
        let pop = PublishRelay<Void>()
        let pushEdit = PublishRelay<Record>()
    }
    
    struct Delegate {
        let editedRecord = PublishRelay<Record>()
    }
}

// MARK: - Input & Output

extension RecordViewModel {
    
    func transform(_ input: Input) -> Output {
        let updateRecord = Signal.merge(
            input.viewDidLoad,
            input.refresh,
            input.viewBecomeActive.map { _ in }
        )
        
        updateRecord
            .withUnretained(self)
            .map { owner, _ in owner.output.record.value }
            .emit(to: output.record)
            .disposed(by: disposeBag)
        
        updateRecord
            .asObservable()
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .userInteractive))
            .withUnretained(self)
            .flatMap { owner, _ in owner.fetchCurrentPhotos() }
            .bind(to: output.mediaList)
            .disposed(by: disposeBag)
        
        delegate.editedRecord
            .bind(to: output.record)
            .disposed(by: disposeBag)
        
        input.seemoreButtonTapped
            .withUnretained(self)
            .map { owner, _ in owner.seemoreMenu }
            .emit(to: output.seemoreMenuPresented)
            .disposed(by: disposeBag)
        
        input.finishButtonTapped
            .emit(with: self) { owner, _ in
                owner.output.finishAlertPresented.accept(owner.finishAlert)
            }
            .disposed(by: disposeBag)
        
        alertAction.save
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .userInteractive))
            .bind(with: self) { owner, _ in
                do {
                    // try owner.saveToAlbums()
                    owner.output.saveCompleteAlertPresented.accept(owner.saveAlert)
                }
            }
            .disposed(by: disposeBag)
        
        alertAction.navigateToHome
            .do { _ in UserDefaultsService.isTracking = false }
            .bind(to: navigation.pop)
            .disposed(by: disposeBag)
        
        menuAction.edit
            .withUnretained(self)
            .map {owner, _ in owner.output.record.value }
            .bind(to: navigation.pushEdit)
            .disposed(by: disposeBag)
        
        return output
    }
}

// MARK: - Album Logic

extension RecordViewModel {
    
    /// 현재 사진 리스트를 반환합니다.
    private func fetchCurrentPhotos() -> Observable<[Media]> {
        let trackingStartDate = output.record.value.trackingStartDate
        fetchResult = photoKitService.fetchAssetResult(
            mediaFetchType: .all,
            date: trackingStartDate,
            ascending: true
        )
        return photoKitService.fetchPhotos(fetchResult)
    }
    
    /// 앨범에 저장합니다.
    private func saveToAlbums() throws {
        let title = output.record.value.title
        try photoKitService.saveAlbum(title: title, assets: fetchResult)
    }
}

// MARK: - Alert

extension RecordViewModel {
    
    /// 기록 종료 Alert
    private var finishAlert: Alert {
        let title = output.record.value.title
        let totalCount = output.mediaList.value.count
        return Alert(
            title: "기록을 종료할까요?",
            message: "총 \(totalCount)장의 '\(title)' 기록 종료 후 앨범에 저장돼요",
            eventButton: .init(title: "종료", action: alertAction.save),
            cancelButton: .init(title: "취소")
        )
    }
    
    /// 앨범 저장 Alert
    private var saveAlert: Alert {
        let title = output.record.value.title
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
