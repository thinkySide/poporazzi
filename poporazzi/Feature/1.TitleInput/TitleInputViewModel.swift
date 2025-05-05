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
    
    @Dependency(\.versionService) private var versionService
    @Dependency(\.liveActivityService) private var liveActivityService
    
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
        let startButtonTapped: Signal<Void>
    }
    
    struct Output {
        let titleText = BehaviorRelay<String>(value: "")
        let isStartButtonEnabled = BehaviorRelay<Bool>(value: false)
        let alertPresented = PublishRelay<AlertModel>()
    }
    
    enum Navigation {
        case pushRecord(Album)
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
        
        input.startButtonTapped
            .emit(with: self) { owner, _ in
                let album = Album(title: owner.output.titleText.value, trackingStartDate: .now)
                owner.navigation.accept(.pushRecord(album))
                owner.liveActivityService.start(
                    albumTitle: album.title,
                    startDate: album.trackingStartDate
                )
                UserDefaultsService.album = album
                UserDefaultsService.isTracking = true
            }
            .disposed(by: disposeBag)
        
        alert
            .bind(with: self) { owner, action in
                switch action {
                case .openAppStore:
                    owner.versionService.openAppStore()
                }
            }
            .disposed(by: disposeBag)
        
#if !DEBUG
        versionService.appStoreAppVersion
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .userInteractive))
            .bind(with: self) { owner, appStoreVersion in
                if appStoreVersion != owner.versionService.deviceAppVersion {
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
