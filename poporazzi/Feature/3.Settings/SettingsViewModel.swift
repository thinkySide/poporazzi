//
//  SettingsViewModel.swift
//  poporazzi
//
//  Created by 김민준 on 5/23/25.
//

import Foundation
import RxSwift
import RxCocoa

final class SettingsViewModel: ViewModel {
    
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

extension SettingsViewModel {
    
    struct Input {
        let writeAppStoreReviviewButtonTapped: Signal<Void>
        let requestFeatureAndImprovementButtonTapped: Signal<Void>
        let shareWithFriendsButtonTapped: Signal<Void>
        
        let poporazziOpenChatRoomButtonTapped: Signal<Void>
        let instagramButtonTapped: Signal<Void>
        let threadButtonTapped: Signal<Void>
    }
    
    struct Output {
        
    }
    
    enum Navigation {
        
    }
}

// MARK: - Transform

extension SettingsViewModel {
    
    func transform(_ input: Input) -> Output {
        input.writeAppStoreReviviewButtonTapped
            .emit(with: self) { owner, _ in
                DeepLinkManager.openAppStoreReview()
            }
            .disposed(by: disposeBag)
        
        input.requestFeatureAndImprovementButtonTapped
            .emit(with: self) { owner, _ in
                DeepLinkManager.openInquiryLink()
            }
            .disposed(by: disposeBag)
        
        input.shareWithFriendsButtonTapped
            .emit(with: self) { owner, _ in
                
            }
            .disposed(by: disposeBag)
        
        input.poporazziOpenChatRoomButtonTapped
            .emit(with: self) { owner, _ in
                
            }
            .disposed(by: disposeBag)
        
        input.instagramButtonTapped
            .emit(with: self) { owner, _ in
                
            }
            .disposed(by: disposeBag)
        
        input.threadButtonTapped
            .emit(with: self) { owner, _ in
                
            }
            .disposed(by: disposeBag)
        
        return output
    }
}
