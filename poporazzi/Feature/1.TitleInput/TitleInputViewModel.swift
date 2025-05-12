//
//  TitleInputViewModel.swift
//  poporazzi
//
//  Created by 김민준 on 4/5/25.
//

import Foundation
import RxSwift
import RxCocoa

final class TitleInputViewModel: ViewModel {
    
    @Dependency(\.liveActivityService) var liveActivityService
    
    private let disposeBag = DisposeBag()
    private let output: Output
    
    let navigation = PublishRelay<Navigation>()
    let alert = PublishRelay<Alert>()
    
    init(output: Output) {
        self.output = output
    }
    
    deinit {
        Log.print(#file, .deinit)
    }
}

// MARK: - Input & Output

extension TitleInputViewModel {
    
    struct Input {
        let titleTextChanged: Signal<String>
        let containScreenshotChanged: Signal<Bool>
        let startButtonTapped: Signal<Void>
    }
    
    struct Output {
        let titleText = BehaviorRelay<String>(value: "")
        let isStartButtonEnabled = BehaviorRelay<Bool>(value: false)
        let isContainScreenshot = BehaviorRelay<Bool>(value: false)
        let alertPresented = PublishRelay<AlertModel>()
    }
    
    enum Navigation {
        case pushRecord(Album, Bool)
    }
    
    enum Alert {
        case openAppStore
    }
}

// MARK: - Transform

extension TitleInputViewModel {
    
    func transform(_ input: Input) -> Output {
        input.titleTextChanged
            .emit(to: output.titleText)
            .disposed(by: disposeBag)
        
        input.titleTextChanged
            .map { !$0.isEmpty }
            .emit(to: output.isStartButtonEnabled)
            .disposed(by: disposeBag)
        
        input.containScreenshotChanged
            .emit(to: output.isContainScreenshot)
            .disposed(by: disposeBag)
        
        input.startButtonTapped
            .emit(with: self) { owner, _ in
                let album = Album(title: owner.output.titleText.value, trackingStartDate: .now)
                let isContainScreenshot = owner.output.isContainScreenshot.value
                owner.navigation.accept(.pushRecord(album, isContainScreenshot))
                owner.output.isContainScreenshot.accept(false)
                owner.liveActivityService.start(to: album)
                HapticManager.notification(type: .success)
                UserDefaultsService.album = album
                UserDefaultsService.isTracking = true
                UserDefaultsService.isContainScreenshot = owner.output.isContainScreenshot.value
            }
            .disposed(by: disposeBag)
        
        alert
            .bind(with: self) { owner, action in
                switch action {
                case .openAppStore:
                    VersionManager.openAppStore()
                }
            }
            .disposed(by: disposeBag)
        
#if !DEBUG
        VersionManager.appStoreAppVersion
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .userInteractive))
            .bind(with: self) { owner, appStoreVersion in
                if appStoreVersion != VersionManager.deviceAppVersion {
                    owner.output.alertPresented.accept(owner.recommendUpdateAlert)
                }
            }
            .disposed(by: disposeBag)
#endif
        
        return output
    }
}

// MARK: - Alert

extension TitleInputViewModel {
    
    /// 업데이트 권장 Alert
    private var recommendUpdateAlert: AlertModel {
        AlertModel(
            title: "새롭게 업데이트된 버전이 있어요!",
            message: "포포라치의 새로운 기능을 이용하기 위해 업데이트가 필요해요 😎",
            eventButton: .init(
                title: "업데이트",
                action: { [weak self] in
                    self?.alert.accept(.openAppStore)
                }
            ),
            cancelButton: .init(title: "다음에")
        )
    }
}
