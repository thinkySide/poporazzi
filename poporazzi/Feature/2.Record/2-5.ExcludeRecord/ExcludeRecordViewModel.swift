//
//  ExcludeRecordViewModel.swift
//  poporazzi
//
//  Created by 김민준 on 5/5/25.
//

import Foundation
import RxSwift
import RxCocoa

final class ExcludeRecordViewModel: ViewModel {
    
    @Dependency(\.persistenceService) private var persistenceService
    @Dependency(\.photoKitService) private var photoKitService
    
    let disposeBag = DisposeBag()
    
    private let output: Output
    
    let navigation = PublishRelay<Navigation>()
    let delegate = PublishRelay<Delegate>()
    let actionSheetAction = PublishRelay<ActionSheetAction>()
    let menuAction = PublishRelay<MenuAction>()
    let contextMenuAction = PublishRelay<ContextMenuAction>()
    
    init(output: Output) {
        self.output = output
    }
    
    deinit {
        Log.print(#file, .deinit)
    }
}

// MARK: - Input & Output

extension ExcludeRecordViewModel {
    
    struct Input {
        let viewDidLoad: Signal<Void>
        let backButtonTapped: Signal<Void>
        
        let selectButtonTapped: Signal<Void>
        let selectCancelButtonTapped: Signal<Void>
        
        let recordCellSelected: Signal<IndexPath>
        let recordCellDeselected: Signal<IndexPath>
        
        let contextMenuPresented: Signal<IndexPath>
        
        let favoriteToolbarButtonTapped: Signal<Void>
        let recoverButtonTapped: Signal<Void>
        let removeButtonTapped: Signal<Void>
    }
    
    struct Output {
        let album: BehaviorRelay<Record>
        
        let mediaList = BehaviorRelay<[Media]>(value: [])
        let selectedRecordCells = BehaviorRelay<[IndexPath]>(value: [])
        let shoudBeFavorite = BehaviorRelay<Bool>(value: true)
        
        let switchSelectMode = PublishRelay<Bool>()
        let viewDidRefresh = PublishRelay<Void>()
        let alertPresented = PublishRelay<AlertModel>()
        let actionSheetPresented = PublishRelay<ActionSheetModel>()
        
        let setupSeeMoreToolbarMenu = BehaviorRelay<[MenuModel]>(value: [])
        let selectedContextMenu = BehaviorRelay<[MenuModel]>(value: [])
        
        let toggleLoading = PublishRelay<Bool>()
    }
    
    enum Navigation {
        case pop
        case updateRecord(Record)
        case presentMediaShareSheet([Any])
    }
    
    enum Delegate {
        case completeSharing
    }
    
    enum MenuAction {
        case share
    }
    
    enum ActionSheetAction {
        case recover([Media])
        case remove([Media])
    }
    
    enum ContextMenuAction {
        case toggleFavorite(Media)
        case share(Media)
        case recover(Media)
        case remove(Media)
    }
}

// MARK: - Transform

extension ExcludeRecordViewModel {
    
    func transform(_ input: Input) -> Output {
        input.viewDidLoad
            .emit(with: self) { owner, _ in
                owner.output.setupSeeMoreToolbarMenu.accept(owner.seemoreToolbarMenu)
            }
            .disposed(by: disposeBag)
        
        Signal.merge(input.viewDidLoad, output.viewDidRefresh.asSignal(), photoKitService.photoLibraryAssetChange)
            .asObservable()
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .userInteractive))
            .withUnretained(self)
            .flatMap { owner, _ in owner.fetchExcludePhotos() }
            .bind(with: self) { owner, mediaList in
                owner.output.mediaList.accept(mediaList)
            }
            .disposed(by: disposeBag)
        
        input.backButtonTapped
            .emit(with: self) { owner, _ in
                owner.navigation.accept(.pop)
            }
            .disposed(by: disposeBag)
        
        input.selectButtonTapped
            .emit(with: self) { owner, _ in
                owner.output.switchSelectMode.accept(true)
                owner.output.shoudBeFavorite.accept(owner.shouldBeFavorite(from: owner.selectedMediaList()))
                HapticManager.impact(style: .light)
            }
            .disposed(by: disposeBag)
        
        input.selectCancelButtonTapped
            .emit(with: self) { owner, _ in
                owner.cancelSelectMode()
            }
            .disposed(by: disposeBag)
        
        input.recordCellSelected
            .emit(with: self) { owner, indexPath in
                var currentCells = owner.output.selectedRecordCells.value
                currentCells.append(indexPath)
                owner.output.selectedRecordCells.accept(currentCells)
                owner.output.shoudBeFavorite.accept(owner.shouldBeFavorite(from: owner.selectedMediaList()))
            }
            .disposed(by: disposeBag)
        
        input.recordCellDeselected
            .emit(with: self) { owner, indexPath in
                var currentCells = owner.output.selectedRecordCells.value
                currentCells.removeAll(where: { $0 == indexPath })
                owner.output.selectedRecordCells.accept(currentCells)
                owner.output.shoudBeFavorite.accept(owner.shouldBeFavorite(from: owner.selectedMediaList()))
            }
            .disposed(by: disposeBag)
        
        input.contextMenuPresented
            .emit(with: self) { owner, indexPath in
                let selectedMedia = owner.output.mediaList.value[indexPath.row]
                let contextMenu = owner.contextMenu(from: selectedMedia)
                owner.output.selectedContextMenu.accept(contextMenu)
            }
            .disposed(by: disposeBag)
        
        input.favoriteToolbarButtonTapped
            .emit(with: self) { owner, _ in
                owner.photoKitService.toggleMediaFavorite(
                    from: owner.selectedAssetIdentifiers(),
                    isFavorite: owner.shouldBeFavorite(from: owner.selectedMediaList())
                )
                owner.cancelSelectMode()
            }
            .disposed(by: disposeBag)
        
        input.recoverButtonTapped
            .emit(with: self) { owner, _ in
                owner.output.actionSheetPresented.accept(owner.recoverActionSheet(from: owner.selectedMediaList()))
            }
            .disposed(by: disposeBag)
        
        input.removeButtonTapped
            .emit(with: self) { owner, _ in
                owner.output.actionSheetPresented.accept(owner.removeActionSheet(from: owner.selectedMediaList()))
            }
            .disposed(by: disposeBag)
        
        actionSheetAction
            .bind(with: self) { owner, action in
                switch action {
                case let .recover(mediaList):
                    var album = owner.output.album.value
                    album.excludeMediaList.subtract(mediaList.map(\.id))
                    owner.output.album.accept(album)
                    
                    owner.output.viewDidRefresh.accept(())
                    owner.cancelSelectMode()
                    
                    owner.navigation.accept(.updateRecord(owner.output.album.value))
                    owner.persistenceService.updateAlbumExcludeMediaList(to: album)
                    
                case let .remove(mediaList):
                    owner.output.toggleLoading.accept(true)
                    let identifiers = mediaList.map(\.id)
                    owner.photoKitService.removePhotos(from: identifiers)
                        .observe(on: MainScheduler.asyncInstance)
                        .bind { isSuccess in
                            if isSuccess {
                                var album = owner.output.album.value
                                album.excludeMediaList.subtract(identifiers)
                                owner.output.album.accept(album)
                                
                                owner.cancelSelectMode()
                                owner.persistenceService.updateAlbumExcludeMediaList(to: album)
                            } else {
                                owner.output.alertPresented.accept(owner.removeFailedAlert)
                            }
                            owner.output.toggleLoading.accept(false)
                        }
                        .disposed(by: owner.disposeBag)
                }
            }
            .disposed(by: disposeBag)
        
        menuAction
            .bind(with: self) { owner , action in
                switch action {
                case .share:
                    owner.photoKitService.fetchShareItemList(from: owner.selectedAssetIdentifiers())
                        .bind { shareItemList in
                            owner.navigation.accept(.presentMediaShareSheet(shareItemList))
                        }
                        .disposed(by: owner.disposeBag)
                }
            }
            .disposed(by: disposeBag)
        
        contextMenuAction
            .bind(with: self) { owner, action in
                switch action {
                case let .toggleFavorite(media):
                    owner.photoKitService.toggleMediaFavorite(
                        from: [media.id],
                        isFavorite: owner.shouldBeFavorite(from: [media])
                    )
                    
                case let .share(media):
                    owner.photoKitService.fetchShareItemList(from: [media.id])
                        .bind { shareItemList in
                            owner.navigation.accept(.presentMediaShareSheet(shareItemList))
                        }
                        .disposed(by: owner.disposeBag)
                    
                case let .recover(media):
                    owner.output.actionSheetPresented.accept(owner.recoverActionSheet(from: [media]))
                    HapticManager.notification(type: .warning)
                    
                case let .remove(media):
                    owner.output.actionSheetPresented.accept(owner.removeActionSheet(from: [media]))
                    HapticManager.notification(type: .warning)
                }
            }
            .disposed(by: disposeBag)
        
        delegate
            .bind(with: self) { owner , delegate in
                switch delegate {
                case .completeSharing:
                    owner.cancelSelectMode()
                }
            }
            .disposed(by: disposeBag)
        
        return output
    }
}

// MARK: - Helper

extension ExcludeRecordViewModel {
    
    /// IndexPath에 대응되는 Media를 반환합니다.
    private func selectedMediaList() -> [Media] {
        output.selectedRecordCells.value.compactMap {
            output.mediaList.value[$0.row]
        }
    }
    
    /// IndexPath에 대응되는 Asset Identifiers를 반환합니다.
    private func selectedAssetIdentifiers() -> [String] {
        selectedMediaList().map(\.id)
    }
    
    /// 선택한 Media의 다음 즐겨찾기 값을 계산합니다.
    private func shouldBeFavorite(from mediaList: [Media]) -> Bool {
        let isFavoriteSet = Set(mediaList.map(\.isFavorite))
        
        if isFavoriteSet.count > 1 {
            return isFavoriteSet.contains(true)
        } else {
            return !(isFavoriteSet.first ?? false)
        }
    }
    
    /// 선택 모드를 취소합니다.
    private func cancelSelectMode() {
        output.selectedRecordCells.accept([])
        output.switchSelectMode.accept(false)
        HapticManager.impact(style: .light)
    }
}

// MARK: - PhotoKit Logic

extension ExcludeRecordViewModel {
    
    /// 제외된 사진을 반환합니다.
    private func fetchExcludePhotos() -> Observable<[Media]> {
        photoKitService.fetchMediaListWithThumbnail(
            from: Array(output.album.value.excludeMediaList),
            option: .normal
        )
    }
}

// MARK: - Alert

extension ExcludeRecordViewModel {
    
    /// 기록 삭제 실패 Alert
    private var removeFailedAlert: AlertModel {
        AlertModel(
            title: "사진을 삭제할 수 없어요",
            message: "사진 라이브러리 권한을 확인해주세요",
            eventButton: .init(title: "확인")
        )
    }
}

// MARK: - Action Sheet

extension ExcludeRecordViewModel {
    
    /// 앨범으로 복구 Action Sheet
    private func recoverActionSheet(from mediaList: [Media]) -> ActionSheetModel {
        ActionSheetModel(
            buttons: [
                .init(title: "\(mediaList.count)장의 기록 앨범으로 복구", style: .default) { [weak self] in
                    self?.actionSheetAction.accept(.recover(mediaList))
                },
                .init(title: "취소", style: .cancel)
            ]
        )
    }
    
    /// 기록 삭제 Action Sheet
    private func removeActionSheet(from mediaList: [Media]) -> ActionSheetModel {
        return ActionSheetModel(
            message: "선택한 기록이 ‘사진’ 앱에서 삭제돼요. 삭제한 항목은 사진 앱의 ‘최근 삭제된 항목’에 30일간 보관돼요.",
            buttons: [
                .init(title: "\(mediaList.count)장의 기록 삭제", style: .destructive) { [weak self] in
                    self?.actionSheetAction.accept(.remove(mediaList))
                },
                .init(title: "취소", style: .cancel)
            ]
        )
    }
}

// MARK: - Menu

extension ExcludeRecordViewModel {
    
    /// 더보기 툴바 버튼 Menu
    private var seemoreToolbarMenu: [MenuModel] {
        let share = MenuModel(symbol: .share, title: "공유하기") { [weak self] in
            self?.menuAction.accept(.share)
        }
        return [share]
    }
    
    /// Context Menu
    private func contextMenu(from media: Media) -> [MenuModel] {
        let favorite = MenuModel(
            symbol: media.isFavorite ? .favoriteRemoveLine : .favoriteActiveLine,
            title: media.isFavorite ? "즐겨찾기 해제" : "즐겨찾기"
        ) { [weak self] in
            self?.contextMenuAction.accept(.toggleFavorite(media))
        }
        let share = MenuModel(symbol: .share, title: "공유하기") { [weak self] in
            self?.contextMenuAction.accept(.share(media))
        }
        let recover = MenuModel(symbol: .recover, title: "앨범으로 복구하기") { [weak self] in
            self?.contextMenuAction.accept(.recover(media))
        }
        let remove = MenuModel(symbol: .removeLine, title: "삭제하기", attributes: .destructive) { [weak self] in
            self?.contextMenuAction.accept(.remove(media))
        }
        return [favorite, share, recover, remove]
    }
}
