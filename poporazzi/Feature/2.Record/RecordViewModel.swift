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
    
    private let state: State
    private let alert = PublishRelay<AlertAction>()
    private let menu = PublishRelay<MenuAction>()
    
    let navigation = PublishRelay<Navigation>()
    let delegate = PublishRelay<Delegate>()
    
    init(state: State) {
        self.state = state
    }
}

// MARK: - State & Action

extension RecordViewModel {
    
    struct State {
        let record: BehaviorRelay<Record>
        let mediaList = BehaviorRelay<[Media]>(value: [])
        let effect = PublishRelay<Effect>()
        
        enum Effect {
            case seemoreMenuPresented(UIMenu)
            case finishAlertPresented(Alert)
            case saveCompleteAlertPresented(Alert)
        }
    }
    
    struct Action {
        let viewBecomeActive: Signal<Notification>
        let refresh: Signal<Void>
        let seemoreButtonTapped: Signal<Void>
        let finishButtonTapped: Signal<Void>
    }
    
    enum AlertAction {
        case save
        case navigateToHome
    }
    
    enum MenuAction {
        case edit
    }
    
    enum Navigation {
        case pop
        case pushEdit(Record)
    }
    
    enum Delegate {
        case editComplete(Record)
    }
}

// MARK: - Transform

extension RecordViewModel {
    
    func transform(_ action: Action) -> State {
        let updateRecord = Signal.merge(
            action.refresh,
            action.viewBecomeActive.map { _ in }
        )
        
        updateRecord
            .withUnretained(self)
            .map { owner, _ in owner.state.record.value }
            .emit(to: state.record)
            .disposed(by: disposeBag)
        
        updateRecord
            .asObservable()
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .userInteractive))
            .withUnretained(self)
            .flatMap { owner, _ in owner.fetchCurrentPhotos() }
            .bind(to: state.mediaList)
            .disposed(by: disposeBag)
        
        action.seemoreButtonTapped
            .withUnretained(self)
            .emit(with: self) { owner, _ in
                owner.state.effect.accept(.seemoreMenuPresented(owner.seemoreMenu))
            }
            .disposed(by: disposeBag)
        
        action.finishButtonTapped
            .emit(with: self) { owner, _ in
                owner.state.effect.accept(.finishAlertPresented(owner.finishAlert))
            }
            .disposed(by: disposeBag)
        
        alert
            .bind(with: self) { owner, action in
                switch action {
                case .save:
                    owner.state.effect.accept(.saveCompleteAlertPresented(owner.saveAlert))
                    
                case .navigateToHome:
                    owner.navigation.accept(.pop)
                    UserDefaultsService.isTracking = false
                }
            }
            .disposed(by: disposeBag)
        
        menu
            .bind(with: self) { owner, action in
                switch action {
                case .edit:
                    let record = owner.state.record.value
                    owner.navigation.accept(.pushEdit(record))
                    UserDefaultsService.isTracking = false
                }
            }
            .disposed(by: disposeBag)
        
        delegate
            .bind(with: self) { owner, action in
                switch action {
                case .editComplete(let record):
                    owner.state.record.accept(record)
                }
            }
            .disposed(by: disposeBag)
        
        return state
    }
}

// MARK: - Album Logic

extension RecordViewModel {
    
    /// 현재 사진 리스트를 반환합니다.
    private func fetchCurrentPhotos() -> Observable<[Media]> {
        let trackingStartDate = state.record.value.trackingStartDate
        fetchResult = photoKitService.fetchAssetResult(
            mediaFetchType: .all,
            date: trackingStartDate,
            ascending: true
        )
        return photoKitService.fetchPhotos(fetchResult)
    }
    
    /// 앨범에 저장합니다.
    private func saveToAlbums() throws {
        let title = state.record.value.title
        try photoKitService.saveAlbum(title: title, assets: fetchResult)
    }
}

// MARK: - Alert

extension RecordViewModel {
    
    /// 기록 종료 Alert
    private var finishAlert: Alert {
        let title = state.record.value.title
        let totalCount = state.mediaList.value.count
        return Alert(
            title: "기록을 종료할까요?",
            message: "총 \(totalCount)장의 '\(title)' 기록 종료 후 앨범에 저장돼요",
            eventButton: .init(
                title: "종료",
                action: { [weak self] in
                    self?.alert.accept(.save)
                }
            ),
            cancelButton: .init(title: "취소")
        )
    }
    
    /// 앨범 저장 Alert
    private var saveAlert: Alert {
        let title = state.record.value.title
        return Alert(
            title: "기록이 종료되었습니다!",
            message: "'\(title)' 앨범을 확인해보세요!",
            eventButton: .init(
                title: "홈으로 돌아가기",
                action: { [weak self] in
                    self?.alert.accept(.navigateToHome)
                }
            )
        )
    }
}

// MARK: - UIAction

extension RecordViewModel {
    
    /// 더보기 메뉴를 반환합니다.
    private var seemoreMenu: UIMenu {
        let editImage = UIImage(systemName: SFSymbol.edit.rawValue)
        let editAction = UIAction(title: "기록 수정", image: editImage) { [weak self] _ in
            self?.menu.accept(.edit)
        }
        return UIMenu(children: [editAction])
    }
}
