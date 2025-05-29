//
//  MyAlbumViewModel.swift
//  poporazzi
//
//  Created by 김민준 on 5/27/25.
//

import UIKit
import RxSwift
import RxCocoa

final class MyAlbumViewModel: ViewModel {
    
    @Dependency(\.photoKitService) private var photoKitService
    
    private let paginationManager = PaginationManager(pageSize: 100, threshold: 10)
    
    private let disposeBag = DisposeBag()
    private let output: Output
    
    
    let navigation = PublishRelay<Navigation>()
    let menuAction = PublishRelay<MenuAction>()
    
    init(output: Output) {
        self.output = output
    }
    
    deinit {
        Log.print(#file, .deinit)
    }
}

// MARK: - Input & Output

extension MyAlbumViewModel {
    
    struct Input {
        let viewDidLoad: Signal<Void>
        
        let willDisplayIndexPath: Signal<IndexPath>
        let cellSelected: Signal<IndexPath>
        let cellDeselected: Signal<IndexPath>
        
        let backButtonTapped: Signal<Void>
        let selectButtonTapped: Signal<Void>
        let selectCancelButtonTapped: Signal<Void>
        
        let favoriteToolbarButtonTapped: Signal<Void>
        let excludeToolbarButtonTapped: Signal<Void>
        let removeToolbarButtonTapped: Signal<Void>
    }
    
    struct Output {
        let album: BehaviorRelay<Album>
        
        let mediaList = BehaviorRelay<[Media]>(value: [])
        let sectionMediaList = BehaviorRelay<SectionMediaList>(value: [])
        let thumbnailList = BehaviorRelay<[Media: UIImage?]>(value: [:])
        
        let isSelectMode = BehaviorRelay<Bool>(value: false)
        let selectedIndexPathList = BehaviorRelay<[IndexPath]>(value: [])
        let shouldBeFavorite = BehaviorRelay<Bool>(value: false)
        
        let viewDidRefresh = PublishRelay<Void>()
        let pagination = PublishRelay<Void>()
    }
    
    enum Navigation {
        case pop
        case presentDetail(Album, UIImage?, [Media], Int)
        case presentMediaShareSheet([Any])
    }
    
    enum MenuAction {
        case editAlbum
        case removeAlbum
        case share
    }
}

// MARK: - Transform

extension MyAlbumViewModel {
    
    func transform(_ input: Input) -> Output {
        
        // 이미지 불러오기(페이지네이션)
        output.pagination
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
                let thumbnailList = Dictionary(uniqueKeysWithValues: mediaList.map {
                    ($0, $0.thumbnail)
                })
                var lastThumnailList = owner.thumbnailList
                lastThumnailList.merge(thumbnailList) { $1 }
                owner.output.thumbnailList.accept(lastThumnailList)
            }
            .disposed(by: disposeBag)
        
        // 미디어 리스트 정보만 불러오기
        Signal.merge(
            input.viewDidLoad,
            output.viewDidRefresh.asSignal(),
            photoKitService.photoLibraryAssetChange
        )
        .emit(with: self) { owner, _ in
            let mediaList = owner.photoKitService.fetchMediaList(from: owner.album)
            owner.output.mediaList.accept(mediaList)
            
            let startDate = owner.album.creationDate
            let sectionMediaList = mediaList.toSectionMediaList(startDate: startDate)
            owner.output.sectionMediaList.accept(sectionMediaList)
            
            owner.paginationManager.reset()
            owner.output.pagination.accept(())
        }
        .disposed(by: disposeBag)
        
        // 현재 보이는 IndexPath를 기준으로 페이지네이션 여부 결정
        input.willDisplayIndexPath
            .emit(with: self) { owner, indexPath in
                let index = owner.index(
                    from: owner.sectionMediaList,
                    indexPath: indexPath
                )
                
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
                    let media = owner.mediaList[indexPath.row]
                    let image = owner.thumbnailList[media] ?? .init()
                    owner.navigation.accept(
                        .presentDetail(
                            owner.album,
                            image,
                            owner.mediaList,
                            owner.index(from: owner.sectionMediaList, indexPath: indexPath)
                        )
                    )
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
                
            }
            .disposed(by: disposeBag)
        
        input.removeToolbarButtonTapped
            .emit(with: self) { owner, _ in
                
            }
            .disposed(by: disposeBag)
        
        menuAction
            .bind(with: self) { owner, action in
                switch action {
                case .editAlbum:
                    print("앨범 수정")
                    
                case .removeAlbum:
                    print("앨범 삭제")
                    
                case .share:
                    let selectedList = owner.selectedMediaList.map(\.id)
                    owner.photoKitService.fetchShareItemList(from: selectedList)
                        .bind { shareItemList in
                            owner.navigation.accept(.presentMediaShareSheet(shareItemList))
                        }
                        .disposed(by: owner.disposeBag)
                }
            }
            .disposed(by: disposeBag)
        
        return output
    }
}

// MARK: - Syntax Sugar

extension MyAlbumViewModel {
    
    var album: Album {
        output.album.value
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
    
    var isSelectMode: Bool {
        output.isSelectMode.value
    }
    
    var selectedIndexPathList: [IndexPath] {
        output.selectedIndexPathList.value
    }
    
    var selectedMediaList: [Media] {
        selectedIndexPathList.compactMap {
            mediaList[index(from: sectionMediaList, indexPath: $0)]
        }
    }
}

// MARK: - Helper

extension MyAlbumViewModel {
    
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

// MARK: - Menu

extension MyAlbumViewModel {
    
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
}
