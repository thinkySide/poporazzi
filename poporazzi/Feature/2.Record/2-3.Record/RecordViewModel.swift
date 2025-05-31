//
//  RecordViewModel.swift
//  poporazzi
//
//  Created by 김민준 on 4/5/25.
//

import UIKit
import RxSwift
import RxCocoa

final class RecordViewModel: ViewModel {
    
    @Dependency(\.persistenceService) private var persistenceService
    @Dependency(\.liveActivityService) private var liveActivityService
    @Dependency(\.photoKitService) private var photoKitService
    
    private let paginationManager = PaginationManager(pageSize: 100, threshold: 10)
    
    private let output: Output
    
    let disposeBag = DisposeBag()
    let navigation = PublishRelay<Navigation>()
    let delegate = PublishRelay<Delegate>()
    let alertAction = PublishRelay<AlertAction>()
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

extension RecordViewModel {
    
    struct Input {
        let viewDidLoad: Signal<Void>
        
        let selectButtonTapped: Signal<Void>
        let selectCancelButtonTapped: Signal<Void>
        
        let willDisplayIndexPath: Signal<IndexPath>
        let cellSelected: Signal<IndexPath>
        let cellDeselected: Signal<IndexPath>
        
        let favoriteToolbarButtonTapped: Signal<Void>
        let excludeToolbarButtonTapped: Signal<Void>
        let removeToolbarButtonTapped: Signal<Void>
        
        let finishButtonTapped: Signal<Void>
    }
    
    struct Output {
        let record: BehaviorRelay<Record>
        
        let mediaList = BehaviorRelay<[Media]>(value: [])
        let sectionMediaList = BehaviorRelay<SectionMediaList>(value: [])
        let thumbnailList = BehaviorRelay<[Media: UIImage?]>(value: [:])
        
        let updateRecordCells = BehaviorRelay<[Media]>(value: [])
        let selectedRecordCells = BehaviorRelay<[IndexPath]>(value: [])
        let shoudBeFavorite = BehaviorRelay<Bool>(value: true)
        
        let viewDidRefresh = PublishRelay<Void>()
        let pagination = PublishRelay<Void>()
        let isSelectMode = BehaviorRelay<Bool>(value: false)
        let toggleLoading = PublishRelay<Bool>()
        
        let alertPresented = PublishRelay<AlertModel>()
        let actionSheetPresented = PublishRelay<ActionSheetModel>()
    }
    
    enum Navigation {
        case finishRecord
        case pushAlbumEdit(Record)
        case presentExcludeRecord(Record)
        case presentFinishModal(Record, SectionMediaList)
        case presentMediaShareSheet([Any])
        case toggleTabBar(Bool)
        case presentPermissionRequestModal
        case pushDetail(Record, UIImage?, [Media], Int)
    }
    
    enum Delegate {
        case startRecord(Record)
        case albumDidEdited(Record)
        case updateExcludeRecord(Record)
        case completeSharing
    }
    
    enum AlertAction {
        case finishWithoutRecord
    }
    
    enum MenuAction {
        case editAlbum
        case excludeRecord
        case noSave
        case share
    }
    
    enum ActionSheetAction {
        case exclude([Media])
        case remove([Media])
    }
    
    enum ContextMenuAction {
        case toggleFavorite(Media)
        case share(Media)
        case exclude(Media)
        case remove(Media)
    }
}

// MARK: - Transform

extension RecordViewModel {
    
    func transform(_ input: Input) -> Output {
        
        // 기본 이미지 불러오기
        output.viewDidRefresh
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .userInteractive))
            .withUnretained(self)
            .map { owner, _ in
                owner.paginationManager.reset()
                return (owner, owner.paginationManager.paginationList(from: owner.mediaList))
            }
            .flatMap { owner, paginationList in
                owner.photoKitService.fetchMediaListWithThumbnail(
                    from: paginationList.map(\.id),
                    option: .normal
                )
            }
            .observe(on: MainScheduler.asyncInstance)
            .bind(with: self) { owner, mediaList in
                let allMediaList = owner.mediaList
                var thumbnailList = owner.thumbnailList
                thumbnailList = thumbnailList.filter { allMediaList.contains($0.key) }
                mediaList.forEach { thumbnailList.updateValue($0.thumbnail, forKey: $0) }
                owner.output.thumbnailList.accept(thumbnailList)
            }
            .disposed(by: disposeBag)
        
        // 페이지네이션 이미지 불러오기
        output.pagination
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .userInteractive))
            .withUnretained(self)
            .map { owner, _ in
                (owner, owner.paginationManager.paginationList(from: owner.mediaList))
            }
            .flatMap { owner, paginationList in
                owner.photoKitService.fetchMediaListWithThumbnail(
                    from: paginationList.map(\.id),
                    option: .normal
                )
            }
            .bind(with: self) { owner, mediaList in
                var thumbnailList = owner.thumbnailList
                for media in mediaList {
                    thumbnailList.updateValue(media.thumbnail, forKey: media)
                }
                owner.output.thumbnailList.accept(thumbnailList)
            }
            .disposed(by: disposeBag)
        
        // 미디어 리스트 정보만 불러오기
        photoKitService.photoLibraryAssetChange
            .asObservable()
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .userInteractive))
            .bind(with: self) { owner, _ in
                do {
                    let mediaList = try owner.photoKitService.fetchMediaList(from: owner.record)
                        .filter { !Set(owner.record.excludeMediaList).contains($0.id) }
                    owner.output.mediaList.accept(mediaList)
                    
                    let sectionMediaList = mediaList.toSectionMediaList(startDate: owner.record.startDate)
                    owner.output.sectionMediaList.accept(sectionMediaList)
                    
                    owner.output.viewDidRefresh.accept(())
                    
                    owner.liveActivityService.update(
                        to: owner.output.record.value,
                        totalCount: mediaList.count
                    )
                } catch {
                    owner.navigation.accept(.presentPermissionRequestModal)
                }
                
                owner.output.viewDidRefresh.accept(())
            }
            .disposed(by: disposeBag)
        
        // 현재 보이는 IndexPath를 기준으로 페이지네이션 여부 결정
        input.willDisplayIndexPath
            .emit(with: self) { owner, indexPath in
                let index = owner.index(from: indexPath)
                
                guard index <= owner.mediaList.count else { return }
                
                if owner.paginationManager.isPagination(to: index) {
                    owner.paginationManager.updateForNextPagination()
                    owner.output.pagination.accept(())
                }
            }
            .disposed(by: disposeBag)
        
        input.selectButtonTapped
            .emit(with: self) { owner, _ in
                owner.output.isSelectMode.accept(true)
                owner.output.shoudBeFavorite.accept(owner.selectedMediaList().shouldBeFavorite)
                owner.navigation.accept(.toggleTabBar(false))
                NameSpace.isSelectionMode = true
                HapticManager.impact(style: .light)
            }
            .disposed(by: disposeBag)
        
        input.selectCancelButtonTapped
            .emit(with: self) { owner, _ in
                owner.cancelSelectMode()
                owner.navigation.accept(.toggleTabBar(true))
                NameSpace.isSelectionMode = false
            }
            .disposed(by: disposeBag)
        
        input.cellSelected
            .emit(with: self) { owner, indexPath in
                switch owner.output.isSelectMode.value {
                case true:
                    var currentCells = owner.output.selectedRecordCells.value
                    currentCells.append(indexPath)
                    owner.output.selectedRecordCells.accept(currentCells)
                    owner.output.shoudBeFavorite.accept(owner.selectedMediaList().shouldBeFavorite)
                    
                case false:
                    let initialImage = owner.output.updateRecordCells.value[indexPath.row].thumbnail
                    owner.navigation.accept(
                        .pushDetail(
                            owner.output.record.value,
                            initialImage,
                            owner.output.mediaList.value,
                            owner.index(from: indexPath)
                        )
                    )
                }
            }
            .disposed(by: disposeBag)
        
        input.cellDeselected
            .emit(with: self) { owner, indexPath in
                var currentCells = owner.output.selectedRecordCells.value
                currentCells.removeAll(where: { $0 == indexPath })
                owner.output.selectedRecordCells.accept(currentCells)
                owner.output.shoudBeFavorite.accept(owner.selectedMediaList().shouldBeFavorite)
            }
            .disposed(by: disposeBag)
        
        input.favoriteToolbarButtonTapped
            .emit(with: self) { owner, _ in
                owner.photoKitService.toggleMediaFavorite(
                    from: owner.selectedAssetIdentifiers(),
                    isFavorite: owner.selectedMediaList().shouldBeFavorite
                )
                owner.cancelSelectMode()
            }
            .disposed(by: disposeBag)
        
        input.excludeToolbarButtonTapped
            .emit(with: self) { owner, _ in
                owner.output.actionSheetPresented.accept(
                    owner.excludeActionSheet(
                        from: owner.selectedMediaList()
                    )
                )
                HapticManager.notification(type: .warning)
            }
            .disposed(by: disposeBag)
        
        input.removeToolbarButtonTapped
            .emit(with: self) { owner, _ in
                owner.output.actionSheetPresented.accept(owner.removeActionSheet(from: owner.selectedMediaList()))
                HapticManager.notification(type: .warning)
            }
            .disposed(by: disposeBag)
        
        input.finishButtonTapped
            .emit(with: self) { owner, _ in
                if owner.output.mediaList.value.isEmpty {
                    owner.output.alertPresented.accept(owner.finishWithoutRecordAlert)
                    HapticManager.notification(type: .warning)
                } else {
                    owner.navigation.accept(.presentFinishModal(
                        owner.output.record.value,
                        owner.output.sectionMediaList.value
                    ))
                }
            }
            .disposed(by: disposeBag)
        
        alertAction
            .bind(with: self) { owner, action in
                switch action {
                case .finishWithoutRecord:
                    owner.navigation.accept(.finishRecord)
                    owner.liveActivityService.stop()
                    UserDefaultsService.trackingAlbumId = ""
                }
            }
            .disposed(by: disposeBag)
        
        actionSheetAction
            .bind(with: self) { owner, action in
                switch action {
                case let .exclude(mediaList):
                    var album = owner.output.record.value
                    album.excludeMediaList.formUnion(mediaList.map(\.id))
                    owner.output.record.accept(album)
                    
                    owner.persistenceService.updateAlbumExcludeMediaList(to: album)
                    
                    owner.output.viewDidRefresh.accept(())
                    owner.cancelSelectMode()
                    
                case let .remove(mediaList):
                    owner.output.toggleLoading.accept(true)
                    owner.photoKitService.removePhotos(from: mediaList.map(\.id))
                        .observe(on: MainScheduler.asyncInstance)
                        .bind { isSuccess in
                            if isSuccess {
                                owner.cancelSelectMode()
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
            .bind(with: self) { owner, action in
                switch action {
                case .editAlbum:
                    owner.navigation.accept(.pushAlbumEdit(owner.output.record.value))
                    
                case .excludeRecord:
                    let album = owner.output.record.value
                    owner.navigation.accept(.presentExcludeRecord(album))
                    
                case .noSave:
                    owner.output.alertPresented.accept(owner.finishWithNoSaveAlert)
                    HapticManager.notification(type: .warning)
                    
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
                        isFavorite: [media].shouldBeFavorite
                    )
                    
                case let .share(media):
                    owner.photoKitService.fetchShareItemList(from: [media.id])
                        .bind { shareItemList in
                            owner.navigation.accept(.presentMediaShareSheet(shareItemList))
                        }
                        .disposed(by: owner.disposeBag)
                    
                case let .exclude(media):
                    owner.output.actionSheetPresented.accept(owner.excludeActionSheet(from: [media]))
                    HapticManager.notification(type: .warning)
                    
                case let .remove(media):
                    owner.output.actionSheetPresented.accept(owner.removeActionSheet(from: [media]))
                    HapticManager.notification(type: .warning)
                }
            }
            .disposed(by: disposeBag)
        
        delegate
            .bind(with: self) { owner, delegate in
                switch delegate {
                case let .startRecord(album):
                    owner.output.record.accept(album)
                    owner.output.viewDidRefresh.accept(())
                    
                case let .albumDidEdited(album):
                    owner.output.record.accept(album)
                    owner.output.viewDidRefresh.accept(())
                    
                case let .updateExcludeRecord(album):
                    owner.output.record.accept(album)
                    owner.output.viewDidRefresh.accept(())
                    
                case .completeSharing:
                    owner.cancelSelectMode()
                }
            }
            .disposed(by: disposeBag)
        
        return output
    }
}

// MARK: - Syntax Sugar

extension RecordViewModel {
    
    var record: Record {
        output.record.value
    }
    
    var mediaList: [Media] {
        output.mediaList.value
    }
    
    var sectionMediaList: SectionMediaList {
        output.sectionMediaList.value
    }
    
    var thumbnailList: [Media: UIImage?] {
        output.thumbnailList.value
    }
}

// MARK: - Helper

extension RecordViewModel {
    
    /// IndexPath에 대응되는 Media를 반환합니다.
    private func selectedMediaList() -> [Media] {
        output.selectedRecordCells.value.compactMap {
            output.mediaList.value[index(from: $0)]
        }
    }
    
    /// IndexPath에 대응되는 Asset Identifiers를 반환합니다.
    private func selectedAssetIdentifiers() -> [String] {
        selectedMediaList().map(\.id)
    }
    
    /// IndexPath의 Section과 Row를 기준으로 몇번째 인덱스인지 반환합니다.
    private func index(from indexPath: IndexPath) -> Int {
        var currentIndex = 0
        for (index, mediaList) in output.sectionMediaList.value.enumerated() {
            if index == indexPath.section {
                currentIndex += indexPath.row
                break
            }
            
            currentIndex += mediaList.1.count
        }
        return currentIndex
    }
    
    /// SectionMediaList의 전체 개수를 반환합니다.
    private func totalMediaCount() -> Int {
        var count = 0
        for (_, mediaList) in output.sectionMediaList.value {
            count += mediaList.count
        }
        return count
    }
    
    /// 선택 모드를 취소합니다.
    private func cancelSelectMode() {
        output.selectedRecordCells.accept([])
        output.isSelectMode.accept(false)
        HapticManager.impact(style: .light)
    }
}

// MARK: - Album Logic

extension RecordViewModel {
    
    /// 전체 Media 리스트를 반환합니다.
    private func fetchAllMediaList(from assetIdentifiers: [String]) -> Observable<[Media]> {
        photoKitService.fetchMediaListWithThumbnail(
            from: assetIdentifiers,
            option: .normal
        )
    }
}

// MARK: - Alert

extension RecordViewModel {
    
    /// 기록 없이 종료 Alert
    private var finishWithoutRecordAlert: AlertModel {
        AlertModel(
            title: "기록을 종료할까요?",
            message: "촬영된 기록이 없어 앨범 저장 없이 종료돼요",
            eventButton: .init(title: "종료", isDestructive: true) { [weak self] in
                self?.alertAction.accept(.finishWithoutRecord)
            },
            cancelButton: .init(title: "취소")
        )
    }
    
    /// 저장 없이 종료 Alert
    private var finishWithNoSaveAlert: AlertModel {
        AlertModel(
            title: "저장 없이 종료할까요?",
            message: "앨범 저장 없이 기록이 종료돼요",
            eventButton: .init(title: "종료", isDestructive: true) { [weak self] in
                self?.alertAction.accept(.finishWithoutRecord)
            },
            cancelButton: .init(title: "취소")
        )
    }
    
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

extension RecordViewModel {
    
    /// 앨범 제외 Action Sheet
    private func excludeActionSheet(from mediaList: [Media]) -> ActionSheetModel {
        let title = output.record.value.title
        return ActionSheetModel(
            message: "선택한 기록이 ‘\(title)’ 앨범에서 제외돼요. 나중에 언제든지 다시 추가할 수 있어요.",
            buttons: [
                .init(title: "\(mediaList.count)장의 기록 앨범에서 제외", style: .default) { [weak self] in
                    self?.actionSheetAction.accept(.exclude(mediaList))
                },
                .init(title: "취소", style: .cancel)
            ]
        )
    }
    
    /// 기록 삭제 Action Sheet
    private func removeActionSheet(from mediaList: [Media]) -> ActionSheetModel {
        ActionSheetModel(
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

extension RecordViewModel {
    
    /// 더보기 Menu
    var seemoreMenu: [MenuModel] {
        let editAlbum = MenuModel(symbol: .edit, title: "앨범 수정") { [weak self] in
            self?.menuAction.accept(.editAlbum)
        }
        let excludeRecord = MenuModel(symbol: .exclude, title: "제외된 기록") { [weak self] in
            self?.menuAction.accept(.excludeRecord)
        }
        let noSave = MenuModel(symbol: .noSave, title: "저장 없이 종료", attributes: .destructive) { [weak self] in
            self?.menuAction.accept(.noSave)
        }
        return [editAlbum, excludeRecord, noSave]
    }
    
    /// 더보기 툴바 버튼 Menu
    var seemoreToolbarMenu: [MenuModel] {
        let share = MenuModel(symbol: .share, title: "공유하기") { [weak self] in
            self?.menuAction.accept(.share)
        }
        return [share]
    }
    
    /// Context Menu
    func contextMenu(from indexPath: IndexPath) -> [MenuModel] {
        let media = output.mediaList.value[indexPath.item]
        let favorite = MenuModel(
            symbol: media.isFavorite ? .favoriteRemoveLine : .favoriteActiveLine,
            title: media.isFavorite ? "즐겨찾기 해제" : "즐겨찾기"
        ) { [weak self] in
            self?.contextMenuAction.accept(.toggleFavorite(media))
        }
        let share = MenuModel(symbol: .share, title: "공유하기") { [weak self] in
            self?.contextMenuAction.accept(.share(media))
        }
        let exclude = MenuModel(symbol: .exclude, title: "앨범에서 제외하기") { [weak self] in
            self?.contextMenuAction.accept(.exclude(media))
        }
        let remove = MenuModel(symbol: .removeLine, title: "삭제하기", attributes: .destructive) { [weak self] in
            self?.contextMenuAction.accept(.remove(media))
        }
        return [favorite, share, exclude, remove]
    }
}
