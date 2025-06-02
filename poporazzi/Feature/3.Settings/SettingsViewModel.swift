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
        let viewDidLoad: Signal<Void>
        
        let writeAppStoreReviviewButtonTapped: Signal<Void>
        let requestFeatureAndImprovementButtonTapped: Signal<Void>
        let shareWithFriendsButtonTapped: Signal<Void>
        
        let poporazziOpenChatRoomButtonTapped: Signal<Void>
        let instagramButtonTapped: Signal<Void>
        let threadButtonTapped: Signal<Void>
    }
    
    struct Output {
        let version = BehaviorRelay<String>(value: "")
    }
    
    enum Navigation {
        case presentShareSheet([Any])
    }
}

// MARK: - Transform

extension SettingsViewModel {
    
    func transform(_ input: Input) -> Output {
        input.viewDidLoad
            .emit(with: self) { owner, _ in
                let version = VersionManager.deviceAppVersion
                owner.output.version.accept(version)
            }
            .disposed(by: disposeBag)
        
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
                owner.navigation.accept(.presentShareSheet([owner.shareMessage]))
            }
            .disposed(by: disposeBag)
        
        input.poporazziOpenChatRoomButtonTapped
            .emit(with: self) { owner, _ in
                DeepLinkManager.openChatRoomLink()
            }
            .disposed(by: disposeBag)
        
        input.instagramButtonTapped
            .emit(with: self) { owner, _ in
                DeepLinkManager.openInstagram()
            }
            .disposed(by: disposeBag)
        
        input.threadButtonTapped
            .emit(with: self) { owner, _ in
                DeepLinkManager.openThread()
            }
            .disposed(by: disposeBag)
        
        return output
    }
}

// MARK: - Helper

extension SettingsViewModel {
    
    /// 친구에게 공유할 메시지
    private var shareMessage: String {
        let appStoreLink = DeepLinkManager.appStoreLink
        return """
        “📸 사진 정리, 이제 포포라치에게 맡겨보세요”
        
        여행이나 데이트, 추억을 남기고 싶은 순간에 포포라치로 자동 앨범 정리를 시작해보세요!
        
        1️⃣ 여행이나 데이트 전 기록 시작 버튼 꾹
        2️⃣ 내 맘대로 즐기며 마음껏 사진 찍기
        3️⃣ 종료 후 자동으로 정리된 앨범 확인하기
        
        필요한 건 순간을 즐기는 마음뿐이에요.
        
        👉 지금 포포라치로 추억을 예쁘게 정리해보세요!
        
        [앱스토어 다운로드 - 포포라치]
        \(appStoreLink)
        """
    }
}
