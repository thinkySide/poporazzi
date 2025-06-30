//
//  MainViewModel.swift
//  poporazzi
//
//  Created by 김민준 on 5/24/25.
//

import Foundation
import RxSwift
import RxCocoa

final class MainViewModel: ViewModel {
    
    @Dependency(\.photoKitService) var photoKitService
    
    private let disposeBag = DisposeBag()
    private let output: Output
    
    let navigation = PublishRelay<Navigation>()
    let delegate = PublishRelay<Delegate>()
    let alertAction = PublishRelay<AlertAction>()
    
    init(output: Output) {
        self.output = output
    }
    
    deinit {
        Log.print(#file, .deinit)
    }
}

// MARK: - Input & Output

extension MainViewModel {
    
    struct Input {
        let viewWillAppear: Signal<Void>
        let albumListTabTapped: Signal<Void>
        let recordTabTaaped: Signal<Void>
        let settingsTabTapped: Signal<Void>
    }
    
    struct Output {
        let selectedTab: BehaviorRelay<Tab>
        let isTracking: BehaviorRelay<Bool>
        let toggleTabBar = PublishRelay<Bool>()
        let alertPresented = PublishRelay<AlertModel>()
    }
    
    enum Navigation {
        case presentAuthRequestModal
        case presentTitleInput
    }
    
    enum Delegate {
        case startRecord
        case finishRecord
        case toggleTabBar(Bool)
        case presentAuthRequestModal
    }
    
    enum AlertAction {
        case navigateToSettings
        case openAppStore
    }
}

// MARK: - Transform

extension MainViewModel {
    
    func transform(_ input: Input) -> Output {
        input.viewWillAppear
            .emit(with: self) { owner, _ in
                switch owner.photoKitService.checkPermission() {
                case .notDetermined:
                    HapticManager.notification(type: .warning)
                    owner.navigation.accept(.presentAuthRequestModal)
                    
                case .denied, .restricted, .limited:
                    HapticManager.notification(type: .error)
                    owner.output.alertPresented.accept(owner.navigateToSettingsAlert)
                    break
                    
                default:
                    break
                }
            }
            .disposed(by: disposeBag)
        
        input.albumListTabTapped
            .map { Tab.albumList }
            .emit(with: self) { owner, tab in
                owner.output.selectedTab.accept(tab)
                owner.output.isTracking.accept(owner.output.isTracking.value)
                HapticManager.impact(style: .soft)
            }
            .disposed(by: disposeBag)
        
        input.recordTabTaaped
            .emit(with: self) { owner, tab in
                let isTracking = owner.output.isTracking.value
                if isTracking {
                    let tab = Tab.record(isTracking: isTracking)
                    owner.output.selectedTab.accept(tab)
                } else {
                    owner.navigation.accept(.presentTitleInput)
                }
                
                owner.output.isTracking.accept(isTracking)
                HapticManager.impact(style: .soft)
            }
            .disposed(by: disposeBag)
        
        input.settingsTabTapped
            .map { Tab.settings }
            .emit(with: self) { owner, tab in
                owner.output.selectedTab.accept(tab)
                owner.output.isTracking.accept(owner.output.isTracking.value)
                HapticManager.impact(style: .soft)
            }
            .disposed(by: disposeBag)
        
        delegate
            .bind(with: self) { owner, delegate in
                switch delegate {
                case .startRecord:
                    owner.output.selectedTab.accept(.record(isTracking: false))
                    owner.output.isTracking.accept(true)
                    
                case .finishRecord:
                    owner.output.selectedTab.accept(.albumList)
                    owner.output.isTracking.accept(false)
                    
                case let .toggleTabBar(bool):
                    owner.output.toggleTabBar.accept(bool)
                    
                case .presentAuthRequestModal:
                    owner.navigation.accept(.presentAuthRequestModal)
                }
            }
            .disposed(by: disposeBag)
        
        alertAction
            .bind(with: self) { owner, action in
                switch action {
                case .navigateToSettings:
                    DeepLinkManager.openSettings()
                    
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

extension MainViewModel {
    
    /// 설정 화면 이동 Alert
    private var navigateToSettingsAlert: AlertModel {
        AlertModel(
            title: String(localized: "포포라치 이용을 위해선 사진 보관함 전체 접근 권한이 필요해요 🥲"),
            message: String(localized: "설정 화면으로 이동 후 권한을 재설정 할 수 있어요"),
            eventButton: .init(title: String(localized: "설정화면 이동")) { [weak self] in
                self?.alertAction.accept(.navigateToSettings)
            },
            cancelButton: .init(title: String(localized: "취소"))
        )
    }
    
    /// 업데이트 권장 Alert
    private var recommendUpdateAlert: AlertModel {
        AlertModel(
            title: String(localized: "새롭게 업데이트된 버전이 있어요!"),
            message: String(localized: "포포라치의 새로운 기능을 이용하기 위해 업데이트가 필요해요 😎"),
            eventButton: .init(
                title: String(localized: "업데이트"),
                action: { [weak self] in
                    self?.alertAction.accept(.openAppStore)
                }
            ),
            cancelButton: .init(title: String(localized: "다음에"))
        )
    }
}
