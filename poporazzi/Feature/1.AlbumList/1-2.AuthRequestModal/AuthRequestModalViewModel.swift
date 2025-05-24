//
//  AuthRequestModalViewModel.swift
//  poporazzi
//
//  Created by 김민준 on 5/21/25.
//

import Foundation
import RxSwift
import RxCocoa

final class AuthRequestModalViewModel: ViewModel {
    
    @Dependency(\.photoKitService) private var photoKitService
    
    private let disposeBag = DisposeBag()
    private let output: Output
    
    let navigation = PublishRelay<Navigation>()
    let alertAction = PublishRelay<AlertAction>()
    
    init(output: Output) {
        self.output = output
    }
    
    deinit {
        Log.print(#file, .deinit)
    }
}

// MARK: - Input & Output

extension AuthRequestModalViewModel {
    
    struct Input {
        let requestAuthButtonTapped: Signal<Void>
    }
    
    struct Output {
        let alertPresented = PublishRelay<AlertModel>()
    }
    
    enum Navigation {
        case dismiss
    }
    
    enum AlertAction {
        case navigateToSettings
    }
}

// MARK: - Transform

extension AuthRequestModalViewModel {
    
    func transform(_ input: Input) -> Output {
        input.requestAuthButtonTapped
            .emit(with: self) { owner, _ in
                let status = owner.photoKitService.checkAuth()
                
                if status == .notDetermined {
                    HapticManager.impact(style: .soft)
                    owner.photoKitService.requestAuth()
                        .observe(on: MainScheduler.asyncInstance)
                        .bind { status in
                            switch status {
                            case .notDetermined:
                                break
                                
                            case .restricted, .denied, .limited:
                                HapticManager.notification(type: .error)
                                owner.output.alertPresented.accept(owner.navigateToSettingsAlert)
                                
                            case .authorized:
                                owner.navigation.accept(.dismiss)
                                
                            @unknown default:
                                break
                            }
                        }
                        .disposed(by: owner.disposeBag)
                } else if status == .authorized {
                    HapticManager.impact(style: .soft)
                    owner.navigation.accept(.dismiss)
                } else {
                    HapticManager.notification(type: .error)
                    owner.output.alertPresented.accept(owner.navigateToSettingsAlert)
                }
            }
            .disposed(by: disposeBag)
        
        alertAction
            .bind(with: self) { owner, action in
                switch action {
                case .navigateToSettings:
                    DeepLinkManager.openSettings()
                }
            }
            .disposed(by: disposeBag)
        
        return output
    }
}

// MARK: - Alert

extension AuthRequestModalViewModel {
    
    /// 설정 화면 이동 Alert
    private var navigateToSettingsAlert: AlertModel {
        AlertModel(
            title: "포포라치 이용을 위해선 사진 보관함 전체 접근 권한이 필요해요 🥲",
            message: "설정 화면으로 이동 후 권한을 재설정 할 수 있어요",
            eventButton: .init(title: "설정화면 이동") { [weak self] in
                self?.alertAction.accept(.navigateToSettings)
            },
            cancelButton: .init(title: "취소")
        )
    }
}
