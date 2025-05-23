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
    }
    
    enum Navigation {
        
    }
}

// MARK: - Transform

extension AlbumListViewModel {
    
    func transform(_ input: Input) -> Output {
        
        input.viewDidLoad
            .emit(with: self) { owner, _ in
                owner.output.albumList.accept(owner.photoKitService.fetchAlbumList())
            }
            .disposed(by: disposeBag)

        return output
    }
}
