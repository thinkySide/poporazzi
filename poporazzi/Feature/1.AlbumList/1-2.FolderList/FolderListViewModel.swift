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
        case pushAlbumDetail(Album)
    }
    
    enum Delegate {
        case viewDidRefresh
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
        
        delegate
            .bind(with: self) { owner, delegate in
                switch delegate {
                case .viewDidRefresh:
                    owner.output.viewDidRefresh.accept(())
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
