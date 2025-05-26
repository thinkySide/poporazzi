//
//  AlbumListViewModel.swift
//  poporazzi
//
//  Created by 김민준 on 5/23/25.
//

import Foundation
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
    }
    
    struct Output {
        let albumList = BehaviorRelay<[Album]>(value: [])
        let updateThumbnail = BehaviorRelay<[Album]>(value: [])
        let viewDidRefresh = PublishRelay<Void>()
    }
    
    enum Navigation {
        case presentPermissionRequestModal
    }
    
    enum Delegate {
        case permissionAuthorized
    }
}

// MARK: - Transform

extension AlbumListViewModel {
    
    func transform(_ input: Input) -> Output {
        Signal.merge(input.viewDidLoad, output.viewDidRefresh.asSignal())
            .emit(with: self) { owner, _ in
                do {
                    let albumList = try owner.photoKitService.fetchAlbumListWithNoThumbnail()
                    owner.output.albumList.accept(albumList)
                    
                    owner.photoKitService.fetchAlbumList(from: albumList)
                        .observe(on: MainScheduler.asyncInstance)
                        .bind { albumList in
                            owner.output.updateThumbnail.accept(albumList)
                        }
                        .disposed(by: owner.disposeBag)
                } catch {
                    owner.navigation.accept(.presentPermissionRequestModal)
                }
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
