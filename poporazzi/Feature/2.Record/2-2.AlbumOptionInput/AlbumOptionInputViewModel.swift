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
    
    @Dependency(\.persistenceService) var persistenceService
    @Dependency(\.photoKitService) var photoKitService
    @Dependency(\.liveActivityService) var liveActivityService
    
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

extension AlbumOptionInputViewModel {
    
    struct Input {
        let backButtonTapped: Signal<Void>
        
        let allFetchChoiceChipTapped: Signal<Void>
        let photoFetchChoiceChipTapped: Signal<Void>
        let videoFetchChoiceChipTapped: Signal<Void>
        
        let selfShootingFilterCheckBoxTapped: Signal<Void>
        let downloadFilterCheckBox: Signal<Void>
        let screenshotFilterCheckBox: Signal<Void>
        
        let startButtonTapped: Signal<Void>
    }
    
    struct Output {
        let titleText: BehaviorRelay<String>
        let mediaFetchOption = BehaviorRelay<MediaFetchOption>(value: .all)
        let mediaFilterOption = BehaviorRelay<MediaFilterOption>(value: .init())
        let isStartButtonEnabled = BehaviorRelay<Bool>(value: true)
        let alertPresented = PublishRelay<AlertModel>()
    }
    
    enum Navigation {
        case pop
        case pushRecord(Album)
        case presentAuthRequestModal
    }
    
    enum Delegate {
        case startRecord
    }
    
    enum AlertAction {
        case navigateToSettings
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
        
        input.allFetchChoiceChipTapped
            .emit(with: self) { owner, _ in
                owner.output.mediaFetchOption.accept(.all)
                owner.output.isStartButtonEnabled.accept(owner.isValidCheckBox())
                HapticManager.impact(style: .soft)
            }
            .disposed(by: disposeBag)
        
        input.photoFetchChoiceChipTapped
            .emit(with: self) { owner, _ in
                owner.output.mediaFetchOption.accept(.photo)
                owner.output.isStartButtonEnabled.accept(owner.isValidCheckBox())
                HapticManager.impact(style: .soft)
            }
            .disposed(by: disposeBag)
        input.videoFetchChoiceChipTapped
            .emit(with: self) { owner, _ in
                owner.output.mediaFetchOption.accept(.video)
                owner.output.isStartButtonEnabled.accept(owner.isValidCheckBox())
                HapticManager.impact(style: .soft)
            }
            .disposed(by: disposeBag)
        
        input.selfShootingFilterCheckBoxTapped
            .emit(with: self) { owner, _ in
                var filter = owner.output.mediaFilterOption.value
                filter.isContainSelfShooting.toggle()
                owner.output.mediaFilterOption.accept(filter)
                owner.output.isStartButtonEnabled.accept(owner.isValidCheckBox())
                if filter.isContainSelfShooting { HapticManager.impact(style: .soft) }
            }
            .disposed(by: disposeBag)
        
        input.downloadFilterCheckBox
            .emit(with: self) { owner, _ in
                var filter = owner.output.mediaFilterOption.value
                filter.isContainDownload.toggle()
                owner.output.mediaFilterOption.accept(filter)
                owner.output.isStartButtonEnabled.accept(owner.isValidCheckBox())
                if filter.isContainDownload { HapticManager.impact(style: .soft) }
            }
            .disposed(by: disposeBag)
        
        input.screenshotFilterCheckBox
            .emit(with: self) { owner, _ in
                var filter = owner.output.mediaFilterOption.value
                filter.isContainScreenshot.toggle()
                owner.output.mediaFilterOption.accept(filter)
                owner.output.isStartButtonEnabled.accept(owner.isValidCheckBox())
                if filter.isContainScreenshot { HapticManager.impact(style: .soft) }
            }
            .disposed(by: disposeBag)
        
        input.startButtonTapped
            .emit(with: self) { owner, _ in
                switch owner.photoKitService.checkAuth() {
                case .notDetermined:
                    HapticManager.notification(type: .warning)
                    owner.navigation.accept(.presentAuthRequestModal)
                    
                case .denied, .restricted, .limited:
                    HapticManager.notification(type: .error)
                    owner.output.alertPresented.accept(owner.navigateToSettingsAlert)
                    break
                    
                case .authorized:
                    owner.startRecord()
                    
                @unknown default:
                    break
                }
            }
            .disposed(by: disposeBag)
        
        delegate
            .bind(with: self) { owner, delegate in
                switch delegate {
                case .startRecord:
                    owner.startRecord()
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

// MARK: - Helper

extension AlbumOptionInputViewModel {
    
    /// 기록을 시작합니다.
    private func startRecord() {
        let album = Album(
            title: output.titleText.value,
            albumType: .creating,
            mediaFetchOption: output.mediaFetchOption.value,
            mediaFilterOption: output.mediaFilterOption.value
        )
        
        navigation.accept(.pushRecord(album))
        liveActivityService.start(to: album)
        HapticManager.notification(type: .success)
        
        try? persistenceService.createAlbum(from: album)
        UserDefaultsService.trackingAlbumId = album.id
    }
}

// MARK: - CheckBox

extension AlbumOptionInputViewModel {
    
    /// 현재 CheckBox 표시 상태로 유효한 상태인지 확인합니다.
    private func isValidCheckBox() -> Bool {
        let fetch = output.mediaFetchOption.value
        let filter = output.mediaFilterOption.value
        
        if fetch == .all || fetch == .photo {
            return filter.isContainSelfShooting
            || filter.isContainDownload
            || filter.isContainScreenshot
        } else {
            return filter.isContainSelfShooting
            || filter.isContainDownload
        }
    }
}

// MARK: - Alert

extension AlbumOptionInputViewModel {
    
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
