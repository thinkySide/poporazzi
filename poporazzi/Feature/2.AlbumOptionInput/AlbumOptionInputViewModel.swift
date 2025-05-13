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
        
        let allSaveChoiceChipTapped: Signal<Void>
        let photoChoiceChipTapped: Signal<Void>
        let videoChoiceChipTapped: Signal<Void>
        
        let selfShootingOptionCheckBoxTapped: Signal<Void>
        let downloadOptionCheckBox: Signal<Void>
        let screenshotOptionCheckBox: Signal<Void>
        
        let startButtonTapped: Signal<Void>
    }
    
    struct Output {
        let titleText: BehaviorRelay<String>
        let mediaFetchOption = BehaviorRelay<MediaFetchOption>(value: .all)
        let mediaFilterOption = BehaviorRelay<MediaFilterOption>(value: .init())
    }
    
    enum Navigation {
        case pop
        case pushRecord(Album, MediaFetchOption, MediaFilterOption)
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
        
        input.allSaveChoiceChipTapped
            .emit(with: self) { owner, _ in
                owner.output.mediaFetchOption.accept(.all)
            }
            .disposed(by: disposeBag)
        
        input.photoChoiceChipTapped
            .emit(with: self) { owner, _ in
                owner.output.mediaFetchOption.accept(.image)
            }
            .disposed(by: disposeBag)
        input.videoChoiceChipTapped
            .emit(with: self) { owner, _ in
                owner.output.mediaFetchOption.accept(.video)
            }
            .disposed(by: disposeBag)
        
        input.selfShootingOptionCheckBoxTapped
            .emit(with: self) { owner, _ in
                var filter = owner.output.mediaFilterOption.value
                filter.isContainSelfShooting.toggle()
                owner.output.mediaFilterOption.accept(filter)
            }
            .disposed(by: disposeBag)
        
        input.downloadOptionCheckBox
            .emit(with: self) { owner, _ in
                var filter = owner.output.mediaFilterOption.value
                filter.isContainDownload.toggle()
                owner.output.mediaFilterOption.accept(filter)
            }
            .disposed(by: disposeBag)
        
        input.screenshotOptionCheckBox
            .emit(with: self) { owner, _ in
                var filter = owner.output.mediaFilterOption.value
                filter.isContainScreenshot.toggle()
                owner.output.mediaFilterOption.accept(filter)
            }
            .disposed(by: disposeBag)
        
        input.startButtonTapped
            .emit(with: self) { owner, _ in
                let fetchOption = owner.output.mediaFetchOption.value
                let filterOption = owner.output.mediaFilterOption.value
                let album = Album(
                    title: owner.output.titleText.value,
                    mediaFetchOption: fetchOption,
                    mediaFilterOption: filterOption
                )
                
                owner.navigation.accept(.pushRecord(album, fetchOption, filterOption))
                owner.liveActivityService.start(to: album)
                HapticManager.notification(type: .success)
                
                try? owner.persistenceService.createAlbum(
                    from: album,
                    fetchOption: fetchOption,
                    filterOption: filterOption
                )
                
                UserDefaultsService.album = album
                UserDefaultsService.isTracking = true
            }
            .disposed(by: disposeBag)
        
        return output
    }
}
