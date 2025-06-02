//
//  AlbumDetailViewModel.swift
//  poporazzi
//
//  Created by 김민준 on 5/27/25.
//

import UIKit
import RxSwift
import RxCocoa

final class AlbumDetailViewModel: ViewModel {
    
    @Dependency(\.photoKitService) private var photoKitService
    
    private let paginationManager = PaginationManager(pageSize: 100, threshold: 10)
    
    private let output: Output
    
    let disposeBag = DisposeBag()
    let navigation = PublishRelay<Navigation>()
    let menuAction = PublishRelay<MenuAction>()
    let contextMenuAction = PublishRelay<ContextMenuAction>()
    let actionSheetAction = PublishRelay<ActionSheetAction>()
    
    init(output: Output) {
        self.output = output
    }
    
    deinit {
        Log.print(#file, .deinit)
    }
}

// MARK: - Input & Output

extension AlbumDetailViewModel {
    
    struct Input {
        let viewDidLoad: Signal<Void>
        let viewWillDisappear: Signal<Void>
        
        let willDisplayIndexPath: Signal<IndexPath>
        let cellSelected: Signal<IndexPath>
        let cellDeselected: Signal<IndexPath>
        
        let backButtonTapped: Signal<Void>
        let selectButtonTapped: Signal<Void>
        let selectCancelButtonTapped: Signal<Void>
        
        let currentScrollOffset: Signal<CGPoint>
        
        let favoriteToolbarButtonTapped: Signal<Void>
        let excludeToolbarButtonTapped: Signal<Void>
        let removeToolbarButtonTapped: Signal<Void>
    }
    
    struct Output {
        let album: BehaviorRelay<Album>
        
        let mediaList = BehaviorRelay<[Media]>(value: [])
        let thumbnailList = BehaviorRelay<[Media: UIImage?]>(value: [:])
        let selectedIndexPathList = BehaviorRelay<[IndexPath]>(value: [])
        
        let isNavigationTitleShown = BehaviorRelay<Bool>(value: false)
        let isSelectMode = BehaviorRelay<Bool>(value: false)
        let shouldBeFavorite = BehaviorRelay<Bool>(value: false)
        
        let viewDidRefresh = PublishRelay<Void>()
        let pagination = PublishRelay<Void>()
        let toggleLoading = PublishRelay<Bool>()
        
        let alertPresented = PublishRelay<AlertModel>()
        let actionSheetPresented = PublishRelay<ActionSheetModel>()
    }
    
    enum Navigation {
        case viewWillDisappear
        case pop
        case pushAlbumEdit(Album)
        case presentDetail(Album, UIImage?, [Media], Int)
        case presentMediaShareSheet([Any])
    }
    
    enum MenuAction {
        case editAlbum
        case removeAlbum
        case share
    }
    
    enum ContextMenuAction {
        case toggleFavorite(Media)
        case share(Media)
        case exclude(Media)
        case remove(Media)
    }
    
    enum ActionSheetAction {
        case exclude([Media])
        case remove([Media])
    }
}

// MARK: - Transform

extension AlbumDetailViewModel {
    
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
                let mediaList = owner.photoKitService.fetchMediaList(from: owner.album)
                owner.output.mediaList.accept(mediaList)
                owner.output.viewDidRefresh.accept(())
            }
            .disposed(by: disposeBag)
        
        // 현재 보이는 IndexPath를 기준으로 페이지네이션 여부 결정
        input.willDisplayIndexPath
            .emit(with: self) { owner, indexPath in
                let index = indexPath.item
                
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
                    
                case false:
                    let index = indexPath.item
                    let media = owner.mediaList[index]
                    let image = owner.thumbnailList[media] ?? .init()
                    owner.navigation.accept(.presentDetail(owner.album, image, owner.mediaList, index))
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
                owner.output.isNavigationTitleShown.accept(point.y >= 80)
            }
            .disposed(by: disposeBag)
        
        input.viewWillDisappear
            .emit(with: self) { owner, _ in
                owner.navigation.accept(.viewWillDisappear)
            }
            .disposed(by: disposeBag)
        
        input.backButtonTapped
            .emit(with: self) { owner, _ in
                owner.navigation.accept(.pop)
            }
            .disposed(by: disposeBag)
        
        input.selectButtonTapped
            .emit(with: self) { owner, _ in
                owner.output.isSelectMode.accept(true)
                owner.output.shouldBeFavorite.accept(true)
                NameSpace.isSelectionMode = true
                HapticManager.impact(style: .light)
            }
            .disposed(by: disposeBag)
        
        input.selectCancelButtonTapped
            .emit(with: self) { owner, _ in
                owner.cancelSelectMode()
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
        
        menuAction
            .bind(with: self) { owner, action in
                switch action {
                case .editAlbum:
                    owner.navigation.accept(.pushAlbumEdit(owner.album))
                    
                case .removeAlbum:
                    HapticManager.notification(type: .warning)
                    owner.photoKitService.removeAlbum(from: [owner.album.id])
                        .observe(on: MainScheduler.asyncInstance)
                        .bind { isSuccess in
                            if isSuccess {
                                owner.navigation.accept(.pop)
                            }
                        }
                        .disposed(by: owner.disposeBag)
                    
                case .share:
                    let selectedList = owner.selectedMediaList.map(\.id)
                    owner.photoKitService.fetchShareItemList(from: selectedList)
                        .observe(on: MainScheduler.asyncInstance)
                        .bind { shareItemList in
                            owner.navigation.accept(.presentMediaShareSheet(shareItemList))
                        }
                        .disposed(by: owner.disposeBag)
                }
            }
            .disposed(by: disposeBag)
        
        actionSheetAction
            .bind(with: self) { owner, action in
                switch action {
                case let .exclude(mediaList):
                    owner.photoKitService.excludePhotos(
                        from: owner.album,
                        to: mediaList.map(\.id)
                    )
                    .observe(on: MainScheduler.asyncInstance)
                    .bind { isSuccess in
                        owner.cancelSelectMode()
                    }
                    .disposed(by: owner.disposeBag)
                    
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
                        .observe(on: MainScheduler.asyncInstance)
                        .bind { shareItemList in
                            owner.navigation.accept(.presentMediaShareSheet(shareItemList))
                        }
                        .disposed(by: owner.disposeBag)
                    
                case let .exclude(media):
                    let actionSheet = owner.excludeActionSheet(from: [media])
                    owner.output.actionSheetPresented.accept(actionSheet)
                    HapticManager.notification(type: .warning)
                    
                case let .remove(media):
                    let actionSheet = owner.removeActionSheet(from: [media])
                    owner.output.actionSheetPresented.accept(actionSheet)
                    HapticManager.notification(type: .warning)
                }
            }
            .disposed(by: disposeBag)
        
        return output
    }
}

// MARK: - Syntax Sugar

extension AlbumDetailViewModel {
    
    var album: Album {
        output.album.value
    }
    
    var mediaList: [Media] {
        output.mediaList.value
    }
    
    var thumbnailList: [Media: UIImage?] {
        output.thumbnailList.value
    }
    
    var isSelectMode: Bool {
        output.isSelectMode.value
    }
    
    var selectedIndexPathList: [IndexPath] {
        output.selectedIndexPathList.value
    }
    
    var selectedMediaList: [Media] {
        selectedIndexPathList.compactMap {
            mediaList[$0.item]
        }
    }
}

// MARK: - Helper

extension AlbumDetailViewModel {
    
    /// Section MediaList에서 해당 IndexPath가 몇번째 인덱스인지 반환합니다.
    private func index(
        from sectionMediaList: SectionMediaList,
        indexPath: IndexPath
    ) -> Int {
        var currentIndex = 0
        for (index, mediaList) in sectionMediaList.enumerated() {
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
        output.selectedIndexPathList.accept([])
        HapticManager.impact(style: .light)
        NameSpace.isSelectionMode = false
    }
}

// MARK: - Alert

extension AlbumDetailViewModel {
    
    /// 기록 삭제 실패 Alert
    private var removeFailedAlert: AlertModel {
        AlertModel(
            title: "사진을 삭제할 수 없어요",
            message: "사진 라이브러리 권한을 확인해주세요",
            eventButton: .init(title: "확인")
        )
    }
}

// MARK: - Menu

extension AlbumDetailViewModel {
    
    /// 더보기 Menu
    var seemoreMenu: [MenuModel] {
        let editAlbum = MenuModel(symbol: .edit, title: "앨범 수정") { [weak self] in
            self?.menuAction.accept(.editAlbum)
        }
        let removeAlbum = MenuModel(symbol: .removeLine, title: "앨범 삭제", attributes: .destructive) { [weak self] in
            self?.menuAction.accept(.removeAlbum)
        }
        return [editAlbum, removeAlbum]
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
        let index = indexPath.item
        let media = mediaList[index]
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

// MARK: - Action Sheet

extension AlbumDetailViewModel {
    
    /// 앨범 제외 Action Sheet
    private func excludeActionSheet(from mediaList: [Media]) -> ActionSheetModel {
        ActionSheetModel(
            message: "선택한 기록이 ‘\(album.title)’ 앨범에서 제외돼요. 나중에 언제든지 다시 추가할 수 있어요.",
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
