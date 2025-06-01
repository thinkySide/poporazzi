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
        case presentAppStoreLinkShareSheet(String, URL)
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
                let appStoreLink = DeepLinkManager.appStoreLink
                if let url = URL(string: appStoreLink) {
                    owner.navigation.accept(.presentAppStoreLinkShareSheet(
                        """
                        사진, 앨범 정리하는게 힘들 땐 포포라치를 사용해보세요!
                        
                        1. 여행이나 데이트 전 기록 시작하기 버튼 꾹 눌러놓기
                        2. 내 맘대로 즐기며 마음껏 사진 찍기
                        3. 다녀온 후 종료 버튼 눌러 앨범으로 쏙 저장하기
                        """,
                        url
                    ))
                }
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
