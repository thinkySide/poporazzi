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
        
        // let folderCellSelected: Signal<IndexPath>
        
        let backButtonTapped: Signal<Void>
    }
    
    struct Output {
        let folder: BehaviorRelay<Album>
        let albumList = BehaviorRelay<[Album]>(value: [])
        let thumbnailList = BehaviorRelay<[String: [UIImage?]]>(value: [:])
        
        let updateThumbnail = PublishRelay<[String]>()
    }
    
    enum Navigation {
        case pop
    }
}

// MARK: - Transform

extension FolderListViewModel {
    
    func transform(_ input: Input) -> Output {
        Signal.merge(
            input.viewDidLoad,
            photoKitService.photoLibraryAssetChange
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
                let thumbnailList = Dictionary(uniqueKeysWithValues: albumList.map {
                    ($0.id, $0.thumbnailList)
                })
                owner.output.thumbnailList.accept(thumbnailList)
                owner.output.updateThumbnail.accept(albumList.map(\.id))
            }
            .disposed(by: disposeBag)
        
        input.backButtonTapped
            .emit(with: self) { owner, _ in
                owner.navigation.accept(.pop)
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
