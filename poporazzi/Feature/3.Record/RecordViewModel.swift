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
    
    @Dependency(\.persistenceService) private var persistenceService
    @Dependency(\.liveActivityService) private var liveActivityService
    @Dependency(\.photoKitService) private var photoKitService
    
    private let disposeBag = DisposeBag()
    private let output: Output
    
    private var currentChunk = 0
    private let chunkSize = 100
    
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
        
        let recentIndexPath: BehaviorRelay<IndexPath>
        
        let recordCellSelected: Signal<IndexPath>
        let recordCellDeselected: Signal<IndexPath>
        
        let contextMenuPresented: Signal<IndexPath>
        
        let favoriteToolbarButtonTapped: Signal<Void>
        let excludeToolbarButtonTapped: Signal<Void>
        let removeToolbarButtonTapped: Signal<Void>
        
        let finishButtonTapped: Signal<Void>
    }
    
    struct Output {
        let album: BehaviorRelay<Album>
        
        let mediaList = BehaviorRelay<[Media]>(value: [])
        let sectionMediaList = BehaviorRelay<SectionMediaList>(value: [])
        
        let updateRecordCells = BehaviorRelay<[Media]>(value: [])
        let selectedRecordCells = BehaviorRelay<[IndexPath]>(value: [])
        let shoudBeFavorite = BehaviorRelay<Bool>(value: true)
        
        let viewDidRefresh = PublishRelay<Void>()
        
        let setupSeeMoreMenu = BehaviorRelay<[MenuModel]>(value: [])
        let setupSeeMoreToolbarMenu = BehaviorRelay<[MenuModel]>(value: [])
        let selectedContextMenu = BehaviorRelay<[MenuModel]>(value: [])
        
        let switchSelectMode = PublishRelay<Bool>()
        let alertPresented = PublishRelay<AlertModel>()
        let actionSheetPresented = PublishRelay<ActionSheetModel>()
        let toggleLoading = PublishRelay<Bool>()
    }
    
    enum Navigation {
        case pop
        case pushAlbumEdit(Album)
        case presentExcludeRecord(Album)
        case presentFinishModal(Album, SectionMediaList)
        case presentMediaShareSheet([Any])
    }
    
    enum Delegate {
        case albumDidEdited(Album)
        case updateExcludeRecord(Album)
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

// MARK: - Chunk

extension RecordViewModel {
    
    /// 현재 청크를 기준으로 에셋 ID 배열을 반환합니다.
    private var chunkAssetIdentifiers: [String] {
        let chunkStart = min(currentChunk, output.mediaList.value.count)
        let chunkEnd = min(chunkSize + chunkStart, output.mediaList.value.count)
        return output.mediaList.value[chunkStart..<chunkEnd].map { $0.id }
    }
    
    /// 다음 청크로 업데이트합니다.
    private func updateChunk() {
        currentChunk += chunkSize
    }
    
    /// 청크를 초기화합니다.
    private func resetChunk() {
        currentChunk = 0
        output.updateRecordCells.accept([])
    }
}

// MARK: - Transform

extension RecordViewModel {
    
    func transform(_ input: Input) -> Output {
        
        input.viewDidLoad
            .emit(with: self) { owner, _ in
                owner.output.setupSeeMoreMenu.accept(owner.seemoreMenu)
                owner.output.setupSeeMoreToolbarMenu.accept(owner.seemoreToolbarMenu)
            }
            .disposed(by: disposeBag)
        
        // 1. 화면 진입 시 기본 이미지 로드
        input.viewDidLoad
            .asObservable()
            .observe(on: MainScheduler.asyncInstance)
            .bind(with: self) { owner, _ in
                owner.output.mediaList.accept(owner.fetchAllMediaListWithNoThumbnail())
                
                let assetIdentifiers = owner.chunkAssetIdentifiers
                owner.fetchAllMediaList(from: assetIdentifiers)
                    .observe(on: MainScheduler.asyncInstance)
                    .bind { mediaList in
                        owner.output.updateRecordCells.accept(mediaList)
                    }
                    .disposed(by: owner.disposeBag)
            }
            .disposed(by: disposeBag)
        
        // 2. 업데이트
        input.recentIndexPath
            .filter { !$0.isEmpty }
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .userInteractive))
            .bind(with: self) { owner, indexPath in
                
                let currentIndex = owner.index(from: indexPath)
                guard currentIndex <= owner.output.mediaList.value.count else { return }
                
                // 마지막 셀이 나타나기 전에 업데이트
                if currentIndex >= (owner.currentChunk + owner.chunkSize - 10) {
                    owner.updateChunk()
                    let assetIdentifiers = owner.chunkAssetIdentifiers
                    
                    owner.fetchAllMediaList(from: assetIdentifiers)
                        .observe(on: MainScheduler.asyncInstance)
                        .bind { mediaList in
                            owner.output.updateRecordCells.accept(mediaList)
                        }
                        .disposed(by: owner.disposeBag)
                }
            }
            .disposed(by: disposeBag)
        
        // 3. 리프레쉬 및 라이브러리 변경 감지
        Signal.merge(output.viewDidRefresh.asSignal(), photoKitService.photoLibraryChange)
            .asObservable()
            .bind(with: self) { owner, _ in
                owner.output.mediaList.accept(owner.fetchAllMediaListWithNoThumbnail())
                owner.resetChunk()
                
                let assetIdentifiers = owner.chunkAssetIdentifiers
                owner.fetchAllMediaList(from: assetIdentifiers)
                    .observe(on: MainScheduler.asyncInstance)
                    .bind { mediaList in
                        owner.output.updateRecordCells.accept(mediaList)
                    }
                    .disposed(by: owner.disposeBag)
            }
            .disposed(by: disposeBag)
        
        output.mediaList
            .bind(with: self) { owner, mediaList in
                owner.output.sectionMediaList.accept(owner.dayCountSections(from: mediaList))
                owner.liveActivityService.update(
                    to: owner.output.album.value,
                    totalCount: mediaList.count
                )
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
                let selectedMedia = owner.output.mediaList.value[owner.index(from: indexPath)]
                let contextMenu = owner.contextMenu(from: selectedMedia)
                owner.output.selectedContextMenu.accept(contextMenu)
            }
            .disposed(by: disposeBag)
        
        input.favoriteToolbarButtonTapped
            .emit(with: self) { owner, _ in
                owner.photoKitService.toggleFavorite(
                    from: owner.selectedAssetIdentifiers(),
                    isFavorite: owner.shouldBeFavorite(from: owner.selectedMediaList())
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
                        owner.output.album.value,
                        owner.output.sectionMediaList.value
                    ))
                }
            }
            .disposed(by: disposeBag)
        
        alertAction
            .bind(with: self) { owner, action in
                switch action {
                case .finishWithoutRecord:
                    owner.navigation.accept(.pop)
                    owner.liveActivityService.stop()
                    UserDefaultsService.trackingAlbumId = ""
                }
            }
            .disposed(by: disposeBag)
        
        actionSheetAction
            .bind(with: self) { owner, action in
                switch action {
                case let .exclude(mediaList):
                    var album = owner.output.album.value
                    album.excludeMediaList.formUnion(mediaList.map(\.id))
                    owner.output.album.accept(album)
                    
                    owner.persistenceService.updateAlbumExcludeMediaList(to: album)
                    
                    owner.output.viewDidRefresh.accept(())
                    owner.cancelSelectMode()
                    
                case let .remove(mediaList):
                    owner.output.toggleLoading.accept(true)
                    owner.photoKitService.deletePhotos(from: mediaList.map(\.id))
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
                    owner.navigation.accept(.pushAlbumEdit(owner.output.album.value))
                    
                case .excludeRecord:
                    let album = owner.output.album.value
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
                    owner.photoKitService.toggleFavorite(
                        from: [media.id],
                        isFavorite: owner.shouldBeFavorite(from: [media])
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
                case let .albumDidEdited(album):
                    owner.output.album.accept(album)
                    owner.output.viewDidRefresh.accept(())
                    
                case let .updateExcludeRecord(album):
                    owner.output.album.accept(album)
                    owner.output.viewDidRefresh.accept(())
                    
                case .completeSharing:
                    owner.cancelSelectMode()
                }
            }
            .disposed(by: disposeBag)
        
        return output
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
    
    /// 시작날짜를 기준으로 생성일이 몇일차인지 반환합니다.
    private func days(from creationDate: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents(
            [.day],
            from: calendar.startOfDay(for: output.album.value.startDate),
            to: calendar.startOfDay(for: creationDate)
        )
        return (components.day ?? 0) + 1
    }
    
    /// 날짜 별로 MediaList를 분리해 반환합니다.
    private func dayCountSections(from allMediaList: [Media]) -> SectionMediaList {
        var dic = [RecordSection: [Media]]()
        
        for media in allMediaList.sortedByCreationDate {
            guard let creationDate = media.creationDate else { continue }
            let days = days(from: creationDate)
            dic[.day(
                order: days,
                date: Calendar.current.startOfDay(for: creationDate)
            ), default: []].append(media)
        }
        
        return dic.keys
            .sorted(by: <)
            .map { ($0, dic[$0] ?? []) }
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

// MARK: - Album Logic

extension RecordViewModel {
    
    /// 썸네일 없이 전체 Media 리스트를 반환합니다.
    ///
    /// - 제외된 사진을 필터링합니다.
    /// - 스크린샷이 제외되었을 때 필터링합니다.
    private func fetchAllMediaListWithNoThumbnail() -> [Media] {
        let album = output.album.value
        return photoKitService.fetchMediaListWithNoThumbnail(from: album)
            .filter { !Set(output.album.value.excludeMediaList).contains($0.id) }
    }
    
    /// 전체 Media 리스트를 반환합니다.
    private func fetchAllMediaList(from assetIdentifiers: [String]) -> Observable<[Media]> {
        photoKitService.fetchMedias(from: assetIdentifiers)
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
        let title = output.album.value.title
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
    private var seemoreMenu: [MenuModel] {
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
        let exclude = MenuModel(symbol: .exclude, title: "앨범에서 제외하기") { [weak self] in
            self?.contextMenuAction.accept(.exclude(media))
        }
        let remove = MenuModel(symbol: .removeLine, title: "삭제하기", attributes: .destructive) { [weak self] in
            self?.contextMenuAction.accept(.remove(media))
        }
        return [favorite, share, exclude, remove]
    }
}
