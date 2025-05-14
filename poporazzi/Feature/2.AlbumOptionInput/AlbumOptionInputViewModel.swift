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
    
    @Dependency(\.persistenceService) var persistenceService
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
        
        let allFetchChoiceChipTapped: Signal<Void>
        let photoFetchChoiceChipTapped: Signal<Void>
        let videoFetchChoiceChipTapped: Signal<Void>
        
        let selfShootingFilterCheckBoxTapped: Signal<Void>
        let downloadFilterCheckBox: Signal<Void>
        let screenshotFilterCheckBox: Signal<Void>
        
        let startButtonTapped: Signal<Void>
    }
    
    struct Output {
        let titleText: BehaviorRelay<String>
        let mediaFetchOption = BehaviorRelay<MediaFetchOption>(value: .all)
        let mediaFilterOption = BehaviorRelay<MediaFilterOption>(value: .init())
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
        
        input.allFetchChoiceChipTapped
            .emit(with: self) { owner, _ in
                owner.output.mediaFetchOption.accept(.all)
            }
            .disposed(by: disposeBag)
        
        input.photoFetchChoiceChipTapped
            .emit(with: self) { owner, _ in
                owner.output.mediaFetchOption.accept(.photo)
            }
            .disposed(by: disposeBag)
        input.videoFetchChoiceChipTapped
            .emit(with: self) { owner, _ in
                owner.output.mediaFetchOption.accept(.video)
            }
            .disposed(by: disposeBag)
        
        input.selfShootingFilterCheckBoxTapped
            .emit(with: self) { owner, _ in
                var filter = owner.output.mediaFilterOption.value
                filter.isContainSelfShooting.toggle()
                owner.output.mediaFilterOption.accept(filter)
            }
            .disposed(by: disposeBag)
        
        input.downloadFilterCheckBox
            .emit(with: self) { owner, _ in
                var filter = owner.output.mediaFilterOption.value
                filter.isContainDownload.toggle()
                owner.output.mediaFilterOption.accept(filter)
            }
            .disposed(by: disposeBag)
        
        input.screenshotFilterCheckBox
            .emit(with: self) { owner, _ in
                var filter = owner.output.mediaFilterOption.value
                filter.isContainScreenshot.toggle()
                owner.output.mediaFilterOption.accept(filter)
            }
            .disposed(by: disposeBag)
        
        input.startButtonTapped
            .emit(with: self) { owner, _ in
                let album = Album(
                    title: owner.output.titleText.value,
                    mediaFetchOption: owner.output.mediaFetchOption.value,
                    mediaFilterOption: owner.output.mediaFilterOption.value
                )
                
                owner.navigation.accept(.pushRecord(album))
                owner.liveActivityService.start(to: album)
                HapticManager.notification(type: .success)
                
                try? owner.persistenceService.createAlbum(from: album)
                UserDefaultsService.trackingAlbumId = album.id
            }
            .disposed(by: disposeBag)
        
        return output
    }
}
