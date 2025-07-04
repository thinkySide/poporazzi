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
    @Dependency(\.userNotificationService) private var userNotificationService
    
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
        
        let willDisplayIndexPath: Signal<IndexPath>
        let cellSelected: Signal<IndexPath>
        let cellDeselected: Signal<IndexPath>
        
        let selectButtonTapped: Signal<Void>
        let selectCancelButtonTapped: Signal<Void>
        let finishButtonTapped: Signal<Void>
        
        let currentScrollOffset: Signal<CGPoint>
        
        let favoriteToolbarButtonTapped: Signal<Void>
        let excludeToolbarButtonTapped: Signal<Void>
        let removeToolbarButtonTapped: Signal<Void>
    }
    
    struct Output {
        let record: BehaviorRelay<Record>
        
        let mediaList = BehaviorRelay<[Media]>(value: [])
        let sectionMediaList = BehaviorRelay<SectionMediaList>(value: [])
        let thumbnailList = BehaviorRelay<[Media: UIImage?]>(value: [:])
        let selectedIndexPathList = BehaviorRelay<[IndexPath]>(value: [])
        
        let isSelectMode = BehaviorRelay<Bool>(value: false)
        let shouldBeFavorite = BehaviorRelay<Bool>(value: true)
        let currentScrollOffset = BehaviorRelay<CGFloat>(value: 0)
        
        let viewDidRefresh = PublishRelay<Void>()
        let pagination = PublishRelay<Void>()
        let toggleLoading = PublishRelay<Bool>()
        
        let alertPresented = PublishRelay<AlertModel>()
        let actionSheetPresented = PublishRelay<ActionSheetModel>()
    }
    
    enum Navigation {
        case stopRecord
        case finishRecord(Record, [Media], [UIImage])
        case pushAlbumEdit(Record)
        case presentExcludeRecord(Record)
        case presentFinishModal(Record, SectionMediaList)
        case presentMediaShareSheet([Any])
        case toggleTabBar(Bool)
        case presentPermissionRequestModal
        case presentDetail(Record, UIImage?, [Media], Int)
    }
    
    enum Delegate {
        case startRecord(Record)
        case albumDidEdited(Record)
        case updateExcludeRecord(Record)
        case completeSharing
        case finishRecord
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
                do {
                    let mediaList = try owner.photoKitService
                        .fetchMediaList(from: owner.record)
                        .filter { !Set(owner.record.excludeMediaList).contains($0.id) }
                    
                    let sectionMediaList = mediaList
                        .toSectionMediaList(startDate: owner.record.startDate)
                    
                    owner.output.mediaList.accept(mediaList)
                    owner.output.sectionMediaList.accept(sectionMediaList)
                    
                    owner.liveActivityService.update(
                        to: owner.output.record.value,
                        totalCount: mediaList.count
                    )
                } catch {
                    owner.navigation.accept(.presentPermissionRequestModal)
                }
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
            .observe(on: MainScheduler.asyncInstance)
            .bind(with: self) { owner, mediaList in
                var thumbnailList = owner.thumbnailList
                mediaList.forEach { thumbnailList.updateValue($0.thumbnail, forKey: $0) }
                owner.output.thumbnailList.accept(thumbnailList)
            }
            .disposed(by: disposeBag)
        
        // 미디어 리스트 정보만 불러오기
        photoKitService.photoLibraryAssetChange
            .asObservable()
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .userInteractive))
            .bind(with: self) { owner, _ in
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
        
        input.cellSelected
            .emit(with: self) { owner, indexPath in
                switch owner.isSelectMode {
                case true:
                    var indexPathList = owner.selectedIndexPathList
                    indexPathList.append(indexPath)
                    owner.output.selectedIndexPathList.accept(indexPathList)
                    owner.output.shouldBeFavorite.accept(owner.selectedMediaList.shouldBeFavorite)
                    print(indexPath)
                    
                case false:
                    let index = owner.index(from: indexPath)
                    let media = owner.mediaList[index]
                    let image = owner.thumbnailList[media] ?? .init()
                    owner.navigation.accept(.presentDetail(owner.record, image, owner.mediaList, index))
                }
            }
            .disposed(by: disposeBag)
        
        input.cellDeselected
            .emit(with: self) { owner, indexPath in
                var indexPathList = owner.selectedIndexPathList
                indexPathList.removeAll(where: { $0 == indexPath })
                owner.output.selectedIndexPathList.accept(indexPathList)
                owner.output.shouldBeFavorite.accept(owner.selectedMediaList.shouldBeFavorite)
            }
            .disposed(by: disposeBag)
        
        input.currentScrollOffset
            .distinctUntilChanged()
            .emit(with: self) { owner, point in
                guard !owner.isSelectMode else { return }
                
                let scrollThreshold: CGFloat = 10
                let currentY = point.y
                
                if currentY <= 0 {
                    owner.navigation.accept(.toggleTabBar(true))
                    return
                }
                
                let previousY = owner.output.currentScrollOffset.value
                let deltaY = currentY - previousY
                
                guard abs(deltaY) > scrollThreshold else { return }
                
                if deltaY > 0 {
                    owner.navigation.accept(.toggleTabBar(false))
                } else {
                    owner.navigation.accept(.toggleTabBar(true))
                }
                
                owner.output.currentScrollOffset.accept(currentY)
            }
            .disposed(by: disposeBag)
        
        input.selectButtonTapped
            .emit(with: self) { owner, _ in
                owner.output.isSelectMode.accept(true)
                owner.output.shouldBeFavorite.accept(owner.selectedMediaList.shouldBeFavorite)
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
        
        input.favoriteToolbarButtonTapped
            .emit(with: self) { owner, _ in
                let selectedMediaList = owner.selectedMediaList
                owner.photoKitService.toggleMediaFavorite(
                    from: selectedMediaList.map(\.id),
                    isFavorite: selectedMediaList.shouldBeFavorite
                )
                owner.cancelSelectMode()
            }
            .disposed(by: disposeBag)
        
        input.excludeToolbarButtonTapped
            .emit(with: self) { owner, _ in
                let selectedMediaList = owner.selectedMediaList
                let actionSheet = owner.excludeActionSheet(from: selectedMediaList)
                owner.output.actionSheetPresented.accept(actionSheet)
                HapticManager.notification(type: .warning)
            }
            .disposed(by: disposeBag)
        
        input.removeToolbarButtonTapped
            .emit(with: self) { owner, _ in
                let actionSheet = owner.removeActionSheet(from: owner.selectedMediaList)
                owner.output.actionSheetPresented.accept(actionSheet)
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
                    HapticManager.impact(style: .light)
                }
            }
            .disposed(by: disposeBag)
        
        alertAction
            .bind(with: self) { owner, action in
                switch action {
                case .finishWithoutRecord:
                    owner.navigation.accept(.stopRecord)
                    owner.liveActivityService.stop()
                    owner.userNotificationService.cancelAllNotification()
                    UserDefaultsService.trackingAlbumId = ""
                }
            }
            .disposed(by: disposeBag)
        
        actionSheetAction
            .bind(with: self) { owner, action in
                switch action {
                case let .exclude(mediaList):
                    var record = owner.record
                    record.excludeMediaList.formUnion(mediaList.map(\.id))
                    owner.output.record.accept(record)
                    
                    owner.persistenceService.updateAlbumExcludeMediaList(to: record)
                    
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
                    owner.photoKitService.fetchShareItemList(from: owner.selectedMediaList.map(\.id))
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
                    
                case .finishRecord:
                    let endDate = owner.mediaList.last?.creationDate
                    var finishRecord = owner.record
                    finishRecord.endDate = endDate
                    
                    var randomImageList = [UIImage]()
                    for thumbnail in owner.thumbnailList.compactMap(\.value) {
                        guard randomImageList.count < 2 else { break }
                        randomImageList.append(thumbnail)
                    }
                    owner.navigation.accept(
                        .finishRecord(
                            finishRecord,
                            owner.mediaList,
                            randomImageList
                        )
                    )
                    
                    owner.persistenceService.updateAlbum(to: finishRecord)
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
    
    var selectedMediaList: [Media] {
        output.selectedIndexPathList.value.compactMap {
            output.mediaList.value[index(from: $0)]
        }
    }
    
    var selectedIndexPathList: [IndexPath] {
        output.selectedIndexPathList.value
    }
    
    var sectionMediaList: SectionMediaList {
        output.sectionMediaList.value
    }
    
    var thumbnailList: [Media: UIImage?] {
        output.thumbnailList.value
    }
    
    var isSelectMode: Bool {
        output.isSelectMode.value
    }
}

// MARK: - Helper

extension RecordViewModel {
    
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
    
    /// 선택 모드를 취소합니다.
    private func cancelSelectMode() {
        output.isSelectMode.accept(false)
        navigation.accept(.toggleTabBar(true))
        output.selectedIndexPathList.accept([])
        HapticManager.impact(style: .light)
        NameSpace.isSelectionMode = false
    }
}

// MARK: - Alert

extension RecordViewModel {
    
    /// 기록 없이 종료 Alert
    private var finishWithoutRecordAlert: AlertModel {
        AlertModel(
            title: String(localized: "기록을 종료할까요?"),
            message: String(localized: "촬영된 기록이 없어 앨범 저장 없이 종료돼요"),
            eventButton: .init(title: String(localized: "종료"), isDestructive: true) { [weak self] in
                self?.alertAction.accept(.finishWithoutRecord)
            },
            cancelButton: .init(title: String(localized: "취소"))
        )
    }
    
    /// 저장 없이 종료 Alert
    private var finishWithNoSaveAlert: AlertModel {
        AlertModel(
            title: String(localized: "저장 없이 종료할까요?"),
            message: String(localized: "앨범 저장 없이 기록이 종료돼요"),
            eventButton: .init(title: String(localized: "종료"), isDestructive: true) { [weak self] in
                self?.alertAction.accept(.finishWithoutRecord)
            },
            cancelButton: .init(title: String(localized: "취소"))
        )
    }
    
    /// 기록 삭제 실패 Alert
    private var removeFailedAlert: AlertModel {
        AlertModel(
            title: String(localized: "사진을 삭제할 수 없어요"),
            message: String(localized: "사진 라이브러리 권한을 확인해주세요"),
            eventButton: .init(title: String(localized: "확인"))
        )
    }
}

// MARK: - Action Sheet

extension RecordViewModel {
    
    /// 앨범 제외 Action Sheet
    private func excludeActionSheet(from mediaList: [Media]) -> ActionSheetModel {
        let title = output.record.value.title
        return ActionSheetModel(
            message: String(localized: "선택한 기록이 ‘\(title)’ 앨범에서 제외돼요. 나중에 언제든지 다시 추가할 수 있어요."),
            buttons: [
                .init(
                    title: String(localized: "\(mediaList.count)장의 기록 앨범에서 제외"),
                    style: .default
                ) { [weak self] in
                    self?.actionSheetAction.accept(.exclude(mediaList))
                },
                .init(title: String(localized: "취소"), style: .cancel)
            ]
        )
    }
    
    /// 기록 삭제 Action Sheet
    private func removeActionSheet(from mediaList: [Media]) -> ActionSheetModel {
        ActionSheetModel(
            message: String(localized: "선택한 기록이 ‘사진’ 앱에서 삭제돼요. 삭제한 항목은 사진 앱의 ‘최근 삭제된 항목’에 30일간 보관돼요."),
            buttons: [
                .init(
                    title: String(localized: "\(mediaList.count)장의 기록 삭제"),
                    style: .destructive
                ) { [weak self] in
                    self?.actionSheetAction.accept(.remove(mediaList))
                },
                .init(title: String(localized: "취소"), style: .cancel)
            ]
        )
    }
}

// MARK: - Menu

extension RecordViewModel {
    
    /// 더보기 Menu
    var seemoreMenu: [MenuModel] {
        let edit = MenuModel(symbol: .edit, title: String(localized: "기록 수정")) { [weak self] in
            self?.menuAction.accept(.editAlbum)
        }
        let excludeRecord = MenuModel(symbol: .exclude, title: String(localized: "제외된 기록")) { [weak self] in
            self?.menuAction.accept(.excludeRecord)
        }
        let noSave = MenuModel(symbol: .noSave, title: String(localized: "저장 없이 종료"), attributes: .destructive) { [weak self] in
            self?.menuAction.accept(.noSave)
        }
        return [edit, excludeRecord, noSave]
    }
    
    /// 더보기 툴바 버튼 Menu
    var seemoreToolbarMenu: [MenuModel] {
        let share = MenuModel(symbol: .share, title: String(localized: "공유하기")) { [weak self] in
            self?.menuAction.accept(.share)
        }
        return [share]
    }
    
    /// Context Menu
    func contextMenu(from indexPath: IndexPath) -> [MenuModel] {
        let media = output.mediaList.value[index(from: indexPath)]
        let favorite = MenuModel(
            symbol: media.isFavorite ? .favoriteRemoveLine : .favoriteActiveLine,
            title: media.isFavorite ? String(localized: "즐겨찾기 해제") : String(localized: "즐겨찾기")
        ) { [weak self] in
            self?.contextMenuAction.accept(.toggleFavorite(media))
        }
        let share = MenuModel(symbol: .share, title: String(localized: "공유하기")) { [weak self] in
            self?.contextMenuAction.accept(.share(media))
        }
        let exclude = MenuModel(symbol: .exclude, title: String(localized: "앨범에서 제외하기")) { [weak self] in
            self?.contextMenuAction.accept(.exclude(media))
        }
        let remove = MenuModel(symbol: .removeLine, title: String(localized: "삭제하기"), attributes: .destructive) { [weak self] in
            self?.contextMenuAction.accept(.remove(media))
        }
        return [favorite, share, exclude, remove]
    }
}
