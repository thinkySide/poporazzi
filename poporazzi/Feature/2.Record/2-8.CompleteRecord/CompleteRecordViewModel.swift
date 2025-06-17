//
//  CompleteRecordViewModel.swift
//  poporazzi
//
//  Created by 김민준 on 6/17/25.
//

import UIKit
import RxSwift
import RxCocoa

final class CompleteRecordViewModel: ViewModel {
    
    @Dependency(\.storeKitService) private var storeKitService
    @Dependency(\.photoKitService) private var photoKitService
    
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

extension CompleteRecordViewModel {
    
    struct Input {
        let shareButtonTapped: Signal<Void>
        let showAlbumButtonTapped: Signal<Void>
        let backToHomeButtonTapped: Signal<Void>
    }
    
    struct Output {
        let record: BehaviorRelay<Record>
        let mediaList: BehaviorRelay<[Media]>
        let randomImageList: BehaviorRelay<[UIImage]>
        
        let toggleLoading = PublishRelay<Bool>()
    }
    
    enum Navigation {
        case completeRecord
        case presentMediaShareSheet([Any])
    }
}

// MARK: - Transform

extension CompleteRecordViewModel {
    
    func transform(_ input: Input) -> Output {
        input.shareButtonTapped
            .emit(with: self) { owner, _ in
                owner.output.toggleLoading.accept(true)
                let identifiers = owner.output.mediaList.value.map(\.id)
                owner.photoKitService.fetchShareItemList(from: identifiers)
                    .observe(on: MainScheduler.asyncInstance)
                    .bind { shareItemList in
                        owner.output.toggleLoading.accept(false)
                        owner.navigation.accept(.presentMediaShareSheet(shareItemList))
                    }
                    .disposed(by: owner.disposeBag)
            }
            .disposed(by: disposeBag)
        
        input.showAlbumButtonTapped
            .emit(with: self) { owner, _ in
                DeepLinkManager.openPhotoAlbum()
                owner.navigation.accept(.completeRecord)
                owner.storeKitService.requestReview()
            }
            .disposed(by: disposeBag)
        
        input.backToHomeButtonTapped
            .emit(with: self) { owner, _ in
                owner.navigation.accept(.completeRecord)
                owner.storeKitService.requestReview()
            }
            .disposed(by: disposeBag)
        
        return output
    }
}
