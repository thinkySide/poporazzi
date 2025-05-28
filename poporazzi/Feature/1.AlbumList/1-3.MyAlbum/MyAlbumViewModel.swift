//
//  MyAlbumViewModel.swift
//  poporazzi
//
//  Created by 김민준 on 5/27/25.
//

import Foundation
import RxSwift
import RxCocoa

final class MyAlbumViewModel: ViewModel {
    
    @Dependency(\.photoKitService) private var photoKitService
    
    private let disposeBag = DisposeBag()
    private let output: Output
    
    let navigation = PublishRelay<Navigation>()
    
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
        let backButtonTapped: Signal<Void>
    }
    
    struct Output {
        let album: BehaviorRelay<Album>
        let mediaList = BehaviorRelay<[Media]>(value: [])
        let mediaListWithThumbnail = BehaviorRelay<[Media]>(value: [])
    }
    
    enum Navigation {
        case pop
    }
}

// MARK: - Transform

extension MyAlbumViewModel {
    
    func transform(_ input: Input) -> Output {
        input.viewDidLoad
            .emit(with: self) { owner, _ in
                let mediaList = owner.photoKitService.fetchMediaList(from: owner.album)
                owner.output.mediaList.accept(mediaList)
            }
            .disposed(by: disposeBag)
        
        output.mediaList
            .withUnretained(self)
            .flatMap {
                $0.photoKitService.fetchMediaListWithThumbnail(
                    from: $1.map(\.id),
                    option: .normal
                )
            }
            .bind(with: self) { owner, mediaList in
                owner.output.mediaListWithThumbnail.accept(mediaList)
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

extension MyAlbumViewModel {
    
    var album: Album {
        output.album.value
    }
    
    var mediaList: [Media] {
        output.mediaList.value
    }
}
