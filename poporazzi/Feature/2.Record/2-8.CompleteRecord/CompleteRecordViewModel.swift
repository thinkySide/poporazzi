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
        let showAlbumButtonTapped: Signal<Void>
        let backToHomeButtonTapped: Signal<Void>
    }
    
    struct Output {
        let record: BehaviorRelay<Record>
        let mediaList: BehaviorRelay<[Media]>
        let randomImageList: BehaviorRelay<[UIImage]>
    }
    
    enum Navigation {
        case completeRecord
    }
}

// MARK: - Transform

extension CompleteRecordViewModel {
    
    func transform(_ input: Input) -> Output {
        
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
