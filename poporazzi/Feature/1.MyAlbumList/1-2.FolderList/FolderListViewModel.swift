//
//  FolderListViewModel.swift
//  poporazzi
//
//  Created by 김민준 on 5/30/25.
//

import UIKit
import RxSwift
import RxCocoa

final class FolderListViewModel: ViewModel {
    
    @Dependency(\.photoKitService) var photoKitService
    
    private let output: Output
    
    let disposeBag = DisposeBag()
    let navigation = PublishRelay<Navigation>()
    let delegate = PublishRelay<Delegate>()
    let menuAction = PublishRelay<MenuAction>()
    
    init(output: Output) {
        self.output = output
    }
    
    deinit {
        Log.print(#file, .deinit)
    }
}

// MARK: - Input & Output

extension FolderListViewModel {
    
    struct Input {
        let viewDidLoad: Signal<Void>
        let viewWillDisappear: Signal<Void>
        
        let folderCellSelected: Signal<IndexPath>
        let backButtonTapped: Signal<Void>
        let seemoreButtonTapped: Signal<Void>
    }
    
    struct Output {
        let folder: BehaviorRelay<Album>
        let albumList = BehaviorRelay<[Album]>(value: [])
        let thumbnailList = BehaviorRelay<[String: [UIImage?]]>(value: [:])
        
        let updateThumbnail = PublishRelay<[String]>()
        
        let viewDidRefresh = PublishRelay<Void>()
    }
    
    enum Navigation {
        case viewWillDisappear
        case pop
        case pushFolderList(Album)
        case pushFolderEdit(Album)
        case pushAlbumDetail(Album)
    }
    
    enum Delegate {
        case viewDidRefresh
        case folderWillUpdate(Album)
    }
    
    enum MenuAction {
        case editFolder
        case removeFolder
    }
}

// MARK: - Transform

extension FolderListViewModel {
    
    func transform(_ input: Input) -> Output {
        Signal.merge(
            photoKitService.photoLibraryCollectionChange,
            output.viewDidRefresh.asSignal()
        )
        .emit(with: self) { owner, _ in
            let albumList = owner.photoKitService.fetchAlbumList(from: owner.folder)
            owner.output.albumList.accept(albumList)
        }
        .disposed(by: disposeBag)
        
        output.albumList
            .withUnretained(self)
            .flatMap { $0.photoKitService.fetchAlbumListWithThumbnail(from: $1) }
            .bind(with: self) { owner, albumList in
                var thumbnailList = owner.thumbnailList
                for album in albumList {
                    thumbnailList.updateValue(album.thumbnailList, forKey: album.id)
                }
                owner.output.thumbnailList.accept(thumbnailList)
                owner.output.updateThumbnail.accept(albumList.map(\.id))
            }
            .disposed(by: disposeBag)
        
        input.folderCellSelected
            .emit(with: self) { owner, indexPath in
                let album = owner.albumList[indexPath.row]
                switch album.albumType {
                case .album: owner.navigation.accept(.pushAlbumDetail(album))
                case .folder: owner.navigation.accept(.pushFolderList(album))
                }
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
        
        input.seemoreButtonTapped
            .emit(with: self) { owner, _ in
                
            }
            .disposed(by: disposeBag)
        
        delegate
            .bind(with: self) { owner, delegate in
                switch delegate {
                case .viewDidRefresh:
                    owner.output.viewDidRefresh.accept(())
                    
                case let .folderWillUpdate(folder):
                    owner.output.folder.accept(folder)
                }
            }
            .disposed(by: disposeBag)
        
        menuAction
            .bind(with: self) { owner, action in
                switch action {
                case .editFolder:
                    owner.navigation.accept(.pushFolderEdit(owner.folder))
                    
                case .removeFolder:
                    HapticManager.notification(type: .warning)
                    owner.photoKitService.removeFolder(from: [owner.folder.id])
                        .observe(on: MainScheduler.asyncInstance)
                        .bind { isSuccess in
                            if isSuccess {
                                owner.navigation.accept(.pop)
                            }
                        }
                        .disposed(by: owner.disposeBag)
                }
            }
            .disposed(by: disposeBag)
        
        return output
    }
}

// MARK: - Syntax Sugar

extension FolderListViewModel {
    
    var folder: Album {
        output.folder.value
    }
    
    var albumList: [Album] {
        output.albumList.value
    }
    
    var thumbnailList: [String: [UIImage?]] {
        output.thumbnailList.value
    }
}

// MARK: - Menu

extension FolderListViewModel {
    
    /// 더보기 Menu
    var seemoreMenu: [MenuModel] {
        let edit = MenuModel(symbol: .edit, title: "폴더 수정") { [weak self] in
            self?.menuAction.accept(.editFolder)
        }
        let remove = MenuModel(symbol: .removeLine, title: "폴더 삭제", attributes: .destructive) { [weak self] in
            self?.menuAction.accept(.removeFolder)
        }
        return [edit, remove]
    }
}
