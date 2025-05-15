//
//  FinishConfirmModalViewModel.swift
//  poporazzi
//
//  Created by 김민준 on 5/11/25.
//

import Foundation
import RxSwift
import RxCocoa

final class FinishConfirmModalViewModel: ViewModel {
    
    @Dependency(\.liveActivityService) private var liveActivityService
    @Dependency(\.photoKitService) private var photoKitService
    @Dependency(\.storeKitService) private var storeKitService
    
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

extension FinishConfirmModalViewModel {
    
    struct Input {
        let saveAsSingleRadioButtonTapped: Signal<Void>
        let saveByDayRadioButtonTapped: Signal<Void>
        let noSaveRadioButtonTapped: Signal<Void>
        let finishButtonTapped: Signal<Void>
        let cancelButtonTapped: Signal<Void>
    }
    
    struct Output {
        let album: BehaviorRelay<Album>
        let sectionMediaList: BehaviorRelay<SectionMediaList>
        let saveOption = BehaviorRelay<AlbumSaveOption>(value: .saveAsSingle)
        let toggleLoading = BehaviorRelay<Bool>(value: false)
        let alertPresented = PublishRelay<AlertModel>()
    }
    
    enum Navigation {
        case dismiss
        case popToRoot
    }
    
    enum AlertAction {
        case linkToPhotoAlbum
        case popToHome
    }
}

// MARK: - Transform

extension FinishConfirmModalViewModel {
    
    func transform(_ input: Input) -> Output {
        input.saveAsSingleRadioButtonTapped
            .map { AlbumSaveOption.saveAsSingle }
            .emit(to: output.saveOption)
            .disposed(by: disposeBag)
        
        input.saveByDayRadioButtonTapped
            .map { AlbumSaveOption.saveByDay }
            .emit(to: output.saveOption)
            .disposed(by: disposeBag)
        
        input.noSaveRadioButtonTapped
            .map { AlbumSaveOption.noSave }
            .emit(to: output.saveOption)
            .disposed(by: disposeBag)
        
        input.finishButtonTapped
            .emit(with: self) { owner, _ in
                switch owner.output.saveOption.value {
                case .saveAsSingle:
                    owner.output.toggleLoading.accept(true)
                    owner.saveAlbumAsSingle()
                        .bind { _ in
                            owner.output.toggleLoading.accept(false)
                            owner.finishRecord()
                        }
                        .disposed(by: owner.disposeBag)
                    
                case .saveByDay:
                    owner.output.toggleLoading.accept(true)
                    owner.saveAlubmByDay()
                        .bind { _ in
                            owner.output.toggleLoading.accept(false)
                            owner.finishRecord()
                        }
                        .disposed(by: owner.disposeBag)
                    
                case .noSave:
                    owner.navigation.accept(.popToRoot)
                    owner.finishRecord()
                }
            }
            .disposed(by: disposeBag)
        
        input.cancelButtonTapped
            .emit(with: self) { owner, _ in
                owner.navigation.accept(.dismiss)
            }
            .disposed(by: disposeBag)
        
        alertAction
            .bind(with: self) { owner, action in
                switch action {
                case .linkToPhotoAlbum:
                    DeepLinkManager.openPhotoAlbum()
                    owner.navigation.accept(.popToRoot)
                    owner.storeKitService.requestReview()
                    
                case .popToHome:
                    owner.navigation.accept(.popToRoot)
                    owner.storeKitService.requestReview()
                }
            }
            .disposed(by: disposeBag)
        
        return output
    }
}

// MARK: - Helper

extension FinishConfirmModalViewModel {
    
    /// 기록을 종료합니다.
    private func finishRecord() {
        liveActivityService.stop()
        output.alertPresented.accept(saveCompleteAlert)
        HapticManager.notification(type: .success)
        UserDefaultsService.trackingAlbumId = ""
    }
}

// MARK: - Album Logic

extension FinishConfirmModalViewModel {
    
    /// 하나로 앨범을 저장합니다.
    private func saveAlbumAsSingle() -> Observable<Void> {
        photoKitService.saveAlbumAsSingle(
            title: output.album.value.title,
            sectionMediaList: output.sectionMediaList.value
        )
    }
    
    /// 일차별로 앨범을 저장합니다.
    private func saveAlubmByDay() -> Observable<Void> {
        photoKitService.saveAlubmByDay(
            title: output.album.value.title,
            sectionMediaList: output.sectionMediaList.value
        )
    }
}

// MARK: - Alert

extension FinishConfirmModalViewModel {
    
    /// 앨범 저장 완료 Alert
    private var saveCompleteAlert: AlertModel {
        let title = output.album.value.title
        return AlertModel(
            title: "기록이 종료되었습니다!",
            message: "사진 앱 내 '\(title)' 앨범을 확인해보세요!",
            eventButton: .init(
                title: "앨범 확인",
                action: { [weak self] in
                    self?.alertAction.accept(.linkToPhotoAlbum)
                }
            ),
            cancelButton: .init(
                title: "홈으로 돌아가기",
                action: { [weak self] in
                    self?.alertAction.accept(.popToHome)
                }
            )
        )
    }
}
