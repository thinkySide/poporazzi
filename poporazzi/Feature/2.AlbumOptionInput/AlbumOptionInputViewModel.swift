//
//  AlbumOptionInputViewModel.swift
//  poporazzi
//
//  Created by 김민준 on 5/13/25.
//

import Foundation
import RxSwift
import RxCocoa

final class AlbumOptionInputViewModel: ViewModel {
    
    @Dependency(\.liveActivityService) var liveActivityService
    
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

extension AlbumOptionInputViewModel {
    
    struct Input {
        let backButtonTapped: Signal<Void>
        let startButtonTapped: Signal<Void>
    }
    
    struct Output {
        let titleText: BehaviorRelay<String>
    }
    
    enum Navigation {
        case pop
        case pushRecord(Album)
    }
}

// MARK: - Transform

extension AlbumOptionInputViewModel {
    
    func transform(_ input: Input) -> Output {
        input.backButtonTapped
            .emit(with: self) { owner, _ in
                owner.navigation.accept(.pop)
            }
            .disposed(by: disposeBag)
        
        input.startButtonTapped
            .emit(with: self) { owner, _ in
                let album = Album(title: owner.output.titleText.value, trackingStartDate: .now)
                owner.navigation.accept(.pushRecord(album))
                owner.liveActivityService.start(to: album)
                HapticManager.notification(type: .success)
                UserDefaultsService.album = album
                UserDefaultsService.isTracking = true
            }
            .disposed(by: disposeBag)
        
        return output
    }
}
