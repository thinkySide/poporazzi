//
//  MyAlbumListViewModel.swift
//  poporazzi
//
//  Created by 김민준 on 5/23/25.
//

import UIKit
import RxSwift
import RxCocoa

final class MyAlbumListViewModel: ViewModel {
    
    @Dependency(\.photoKitService) var photoKitService
    
    private let disposeBag = DisposeBag()
    private let output: Output
    
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

extension MyAlbumListViewModel {
    
    struct Input {
        let viewDidLoad: Signal<Void>
        let albumCellSelected: Signal<IndexPath>
    }
    
    struct Output {
        let albumList = BehaviorRelay<[Album]>(value: [])
        let thumbnailList = BehaviorRelay<[Album: [UIImage?]]>(value: [:])
        
        let viewDidRefresh = PublishRelay<Void>()
    }
    
    enum Navigation {
        case presentPermissionRequestModal
        case pushFolderList(Album)
        case pushAlbumDetail(Album)
    }
    
    enum Delegate {
        case permissionAuthorized
        case viewDidRefresh
    }
}

// MARK: - Transform

extension MyAlbumListViewModel {
    
    func transform(_ input: Input) -> Output {
        Signal.merge(
            output.viewDidRefresh.asSignal(),
            photoKitService.photoLibraryCollectionChange
        )
        .asObservable()
        .observe(on: ConcurrentDispatchQueueScheduler(qos: .userInteractive))
        .bind(with: self) { owner, _ in
            do {
                let albumList = try owner.photoKitService.fetchAllAlbumList()
                owner.output.albumList.accept(albumList)
            } catch {
                owner.navigation.accept(.presentPermissionRequestModal)
            }
        }
        .disposed(by: disposeBag)
        
        output.albumList
            .withUnretained(self)
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .userInteractive))
            .flatMap { $0.photoKitService.fetchAlbumListWithThumbnail(from: $1) }
            .bind(with: self) { owner, albumList in
                var thumbnailList: [Album: [UIImage?]] = [:]
                albumList.forEach { thumbnailList.updateValue($0.thumbnailList, forKey: $0) }
                owner.output.thumbnailList.accept(thumbnailList)
            }
            .disposed(by: disposeBag)
        
        input.albumCellSelected
            .emit(with: self) { owner, indexPath in
                let album = owner.albumList[indexPath.row]
                switch album.albumType {
                case .album: owner.navigation.accept(.pushAlbumDetail(album))
                case .folder: owner.navigation.accept(.pushFolderList(album))
                }
            }
            .disposed(by: disposeBag)
        
        delegate
            .bind(with: self) { owner, delegate in
                switch delegate {
                case .permissionAuthorized:
                    owner.output.viewDidRefresh.accept(())
                    
                case .viewDidRefresh:
                    owner.output.viewDidRefresh.accept(())
                }
            }
            .disposed(by: disposeBag)
        
        return output
    }
}

// MARK: - Syntax Sugar

extension MyAlbumListViewModel {
    
    var albumList: [Album] {
        output.albumList.value
    }
    
    var thumbnailList: [Album: [UIImage?]] {
        output.thumbnailList.value
    }
}
