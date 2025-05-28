//
//  AlbumListViewModel.swift
//  poporazzi
//
//  Created by 김민준 on 5/23/25.
//

import UIKit
import RxSwift
import RxCocoa

final class AlbumListViewModel: ViewModel {
    
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

extension AlbumListViewModel {
    
    struct Input {
        let viewDidLoad: Signal<Void>
        let albumCellSelected: Signal<IndexPath>
    }
    
    struct Output {
        let albumList = BehaviorRelay<[Record]>(value: [])
        let updateThumbnail = BehaviorRelay<[Record]>(value: [])
        let viewDidRefresh = PublishRelay<Void>()
    }
    
    enum Navigation {
        case presentPermissionRequestModal
        case pushMyAlbum(Record)
    }
    
    enum Delegate {
        case permissionAuthorized
    }
}

// MARK: - Transform

extension AlbumListViewModel {
    
    func transform(_ input: Input) -> Output {
        Signal.merge(
            input.viewDidLoad,
            output.viewDidRefresh.asSignal(),
            photoKitService.photoLibraryCollectionChange
        )
        .emit(with: self) { owner, _ in
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
            .flatMap { $0.photoKitService.fetchAlbumListWithThumbnail(from: $1) }
            .bind(with: self) { owner, albumList in
                owner.output.updateThumbnail.accept(albumList)
            }
            .disposed(by: disposeBag)
        
        input.albumCellSelected
            .emit(with: self) { owner, indexPath in
                let album = owner.output.albumList.value[indexPath.row]
                owner.navigation.accept(.pushMyAlbum(album))
            }
            .disposed(by: disposeBag)
        
        delegate
            .bind(with: self) { owner, delegate in
                switch delegate {
                case .permissionAuthorized:
                    owner.output.viewDidRefresh.accept(())
                }
            }
            .disposed(by: disposeBag)
        
        return output
    }
}
