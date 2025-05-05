//
//  RecordViewModel.swift
//  poporazzi
//
//  Created by 김민준 on 4/5/25.
//

import Foundation
import RxSwift
import RxCocoa

final class RecordViewModel: ViewModel {
    
    @Dependency(\.liveActivityService) private var liveActivityService
    @Dependency(\.photoKitService) private var photoKitService
    
    private let disposeBag = DisposeBag()
    private let output: Output
    
    let navigation = PublishRelay<Navigation>()
    let delegate = PublishRelay<Delegate>()
    let alertAction = PublishRelay<AlertAction>()
    let actionSheetAction = PublishRelay<ActionSheetAction>()
    let menuAction = PublishRelay<MenuAction>()
    
    init(output: Output) {
        self.output = output
    }
    
    deinit {
        Log.print(#file, .deinit)
    }
}

// MARK: - Input & Output

extension RecordViewModel {
    
    struct Input {
        let viewDidLoad: Signal<Void>
        let selectButtonTapped: Signal<Void>
        let selectCancelButtonTapped: Signal<Void>
        let recordCellTapped: Signal<IndexPath>
        let removeButtonTapped: Signal<Void>
        let finishButtonTapped: Signal<Void>
    }
    
    struct Output {
        let album: BehaviorRelay<Album>
        let mediaList = BehaviorRelay<[Media]>(value: [])
        let selectedRecordCells = BehaviorRelay<[IndexPath]>(value: [])
        let viewDidRefresh = PublishRelay<Void>()
        let setupSeeMoreMenu = BehaviorRelay<[MenuModel]>(value: [])
        let switchSelectMode = PublishRelay<Bool>()
        let alertPresented = PublishRelay<AlertModel>()
        let actionSheetPresented = PublishRelay<ActionSheetModel>()
    }
    
    enum Navigation {
        case pop
        case pushEdit(Album)
    }
    
    enum Delegate {
        case momentDidEdited(Album)
    }
    
    enum AlertAction {
        case save
        case popToHome
    }
    
    enum ActionSheetAction {
        case remove
    }
    
    enum MenuAction {
        case edit
    }
}

// MARK: - Transform

extension RecordViewModel {
    
    func transform(_ input: Input) -> Output {
        input.viewDidLoad
            .emit(with: self) { owner, _ in
                owner.output.setupSeeMoreMenu.accept(owner.seemoreMenu)
            }
            .disposed(by: disposeBag)
        
        Signal.merge(output.viewDidRefresh.asSignal(), photoKitService.photoLibraryChange)
            .asObservable()
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .userInteractive))
            .withUnretained(self)
            .flatMap { owner, _ in owner.fetchCurrentPhotos() }
            .bind(with: self) { owner, mediaList in
                owner.output.mediaList.accept(mediaList)
                owner.liveActivityService.update(
                    albumTitle: owner.output.album.value.title,
                    startDate: owner.output.album.value.trackingStartDate,
                    totalCount: mediaList.count
                )
            }
            .disposed(by: disposeBag)
        
        input.selectButtonTapped
            .map { true }
            .emit(to: output.switchSelectMode)
            .disposed(by: disposeBag)
        
        input.selectCancelButtonTapped
            .emit(with: self) { owner, _ in
                owner.output.selectedRecordCells.accept([])
                owner.output.switchSelectMode.accept(false)
            }
            .disposed(by: disposeBag)
        
        input.recordCellTapped
            .emit(with: self) { owner, indexPath in
                var currentCells = owner.output.selectedRecordCells.value
                if let index = currentCells.firstIndex(of: indexPath) {
                    currentCells.remove(at: index)
                } else {
                    currentCells.append(indexPath)
                }
                owner.output.selectedRecordCells.accept(currentCells)
            }
            .disposed(by: disposeBag)
        
        input.removeButtonTapped
            .emit(with: self) { owner, _ in
                owner.output.actionSheetPresented.accept(owner.removeActionSheet)
            }
            .disposed(by: disposeBag)
        
        input.finishButtonTapped
            .emit(with: self) { owner, _ in
                owner.output.alertPresented.accept(owner.finishConfirmAlert)
            }
            .disposed(by: disposeBag)
        
        alertAction
            .bind(with: self) { owner, action in
                switch action {
                case .save:
                    if owner.output.mediaList.value.isEmpty {
                        owner.navigation.accept(.pop)
                    } else {
                        try? owner.saveToAlbums()
                        owner.output.alertPresented.accept(owner.saveCompleteAlert)
                    }
                    
                    owner.liveActivityService.stop()
                    UserDefaultsService.isTracking = false
                    
                case .popToHome:
                    owner.navigation.accept(.pop)
                }
            }
            .disposed(by: disposeBag)
        
        actionSheetAction
            .bind(with: self) { owner, action in
                switch action {
                case .remove:
                    let assetIdentifiers = owner.output.mediaList.value.map { $0.id }
                    try? owner.photoKitService.deletePhotos(from: assetIdentifiers)
                }
            }
            .disposed(by: disposeBag)
        
        menuAction
            .bind(with: self) { owner, action in
                switch action {
                case .edit:
                    let album = owner.output.album.value
                    owner.navigation.accept(.pushEdit(album))
                }
            }
            .disposed(by: disposeBag)
        
        delegate
            .bind(with: self) { owner, delegate in
                switch delegate {
                case .momentDidEdited(let record):
                    owner.output.album.accept(record)
                    owner.output.viewDidRefresh.accept(())
                }
            }
            .disposed(by: disposeBag)
        
        return output
    }
}

// MARK: - Album Logic

extension RecordViewModel {
    
    /// 현재 사진 리스트를 반환합니다.
    private func fetchCurrentPhotos() -> Observable<[Media]> {
        let trackingStartDate = output.album.value.trackingStartDate
        return photoKitService.fetchPhotos(date: trackingStartDate)
    }
    
    /// 앨범에 저장합니다.
    private func saveToAlbums() throws {
        let title = output.album.value.title
        try photoKitService.saveAlbum(title: title)
    }
}

// MARK: - Alert

extension RecordViewModel {
    
    /// 기록 종료 확인 Alert
    private var finishConfirmAlert: AlertModel {
        let title = output.album.value.title
        let totalCount = output.mediaList.value.count
        let message = output.mediaList.value.isEmpty
        ? "촬영된 기록이 없어 앨범 저장 없이 종료돼요"
        : "총 \(totalCount)장의 '\(title)' 기록이 종료 후 앨범에 저장돼요"
        return AlertModel(
            title: "기록을 종료할까요?",
            message: message,
            eventButton: .init(
                title: "종료",
                action: { [weak self] in
                    self?.alertAction.accept(.save)
                }
            ),
            cancelButton: .init(title: "취소")
        )
    }
    
    /// 앨범 저장 완료 Alert
    private var saveCompleteAlert: AlertModel {
        let title = output.album.value.title
        return AlertModel(
            title: "기록이 종료되었습니다!",
            message: "'\(title)' 앨범을 확인해보세요!",
            eventButton: .init(
                title: "홈으로 돌아가기",
                action: { [weak self] in
                    self?.alertAction.accept(.popToHome)
                }
            )
        )
    }
}

// MARK: - Action Sheet

extension RecordViewModel {
    
    /// 기록 삭제 Action Sheet
    private var removeActionSheet: ActionSheetModel {
        let selectedCount = output.selectedRecordCells.value.count
        return ActionSheetModel(
            message: "선택한 기록이 ‘사진’ 앱에서 삭제돼요. 삭제한 항목은 사진 앱의 ‘최근 삭제된 항목’에 30일간 보관돼요.",
            buttons: [
                .init(title: "\(selectedCount)장의 기록 삭제", style: .destructive) { [weak self] in
                    self?.actionSheetAction.accept(.remove)
                },
                .init(title: "취소", style: .cancel)
            ]
        )
    }
}

// MARK: - Menu

extension RecordViewModel {
    
    /// 더보기 Menu
    private var seemoreMenu: [MenuModel] {
        let edit = MenuModel(symbol: .edit, title: "기록 수정") { [weak self] in
            self?.menuAction.accept(.edit)
        }
        return [edit]
    }
}
