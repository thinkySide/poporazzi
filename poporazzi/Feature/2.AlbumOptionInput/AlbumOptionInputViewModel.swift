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
        let mediaFetchType = BehaviorRelay<MediaFetchType>(value: .all)
        let mediaFetchDetailType = BehaviorRelay<[MediaDetialFetchType]>(value: [.selfShooting])
    }
    
    enum Navigation {
        case pop
        case pushRecord(Album, MediaFetchType, [MediaDetialFetchType])
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
                owner.output.mediaFetchType.accept(.all)
            }
            .disposed(by: disposeBag)
        
        input.photoChoiceChipTapped
            .emit(with: self) { owner, _ in
                owner.output.mediaFetchType.accept(.image)
            }
            .disposed(by: disposeBag)
        input.videoChoiceChipTapped
            .emit(with: self) { owner, _ in
                owner.output.mediaFetchType.accept(.video)
            }
            .disposed(by: disposeBag)
        
        input.selfShootingOptionCheckBoxTapped
            .emit(with: self) { owner, _ in
                owner.updateMediaFetchDetailType(.selfShooting)
            }
            .disposed(by: disposeBag)
        
        input.downloadOptionCheckBox
            .emit(with: self) { owner, _ in
                owner.updateMediaFetchDetailType(.download)
            }
            .disposed(by: disposeBag)
        
        input.screenshotOptionCheckBox
            .emit(with: self) { owner, _ in
                owner.updateMediaFetchDetailType(.screenshot)
            }
            .disposed(by: disposeBag)
        
        input.startButtonTapped
            .emit(with: self) { owner, _ in
                let album = Album(title: owner.output.titleText.value, trackingStartDate: .now)
                let fetchType = owner.output.mediaFetchType.value
                let detailTypes = owner.output.mediaFetchDetailType.value
                owner.navigation.accept(.pushRecord(album, fetchType, detailTypes))
                owner.liveActivityService.start(to: album)
                HapticManager.notification(type: .success)
                UserDefaultsService.album = album
                UserDefaultsService.isTracking = true
            }
            .disposed(by: disposeBag)
        
        return output
    }
}

// MARK: - Helper

extension AlbumOptionInputViewModel {
    
    /// 미디어 세부 항목을 업데이트 후 상태를 업데이트합니다.
    private func updateMediaFetchDetailType(_ detailFetchType: MediaDetialFetchType) {
        var details = output.mediaFetchDetailType.value
        if details.contains(detailFetchType) {
            details.removeAll(where: { $0 == detailFetchType })
        } else {
            details.append(detailFetchType)
        }
        output.mediaFetchDetailType.accept(details)
    }
}
