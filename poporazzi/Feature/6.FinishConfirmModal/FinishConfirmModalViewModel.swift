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
        let finishButtonTapped: Signal<Void>
        let cancelButtonTapped: Signal<Void>
    }
    
    struct Output {
        let album: BehaviorRelay<Album>
        let sectionMediaList: BehaviorRelay<SectionMediaList>
        let saveOption = BehaviorRelay<AlbumSaveOption?>(value: nil)
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
        
        input.finishButtonTapped
            .emit(with: self) { owner, _ in
                do {
                    try owner.saveToAlbums()
                    HapticManager.notification(type: .success)
                    owner.output.alertPresented.accept(owner.saveCompleteAlert)
                    owner.liveActivityService.stop()
                    UserDefaultsService.excludeAssets.removeAll()
                    UserDefaultsService.isTracking = false
                } catch {
                    print(error)
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
                    
                case .popToHome:
                    owner.navigation.accept(.popToRoot)
                }
            }
            .disposed(by: disposeBag)
        
        return output
    }
}

// MARK: - Album Logic

extension FinishConfirmModalViewModel {
    
    /// 앨범에 저장합니다.
    private func saveToAlbums() throws {
        try photoKitService.saveAlbum(
            title: output.album.value.title,
            option: output.saveOption.value,
            sectionMediaList: output.sectionMediaList.value,
            excludeAssets: UserDefaultsService.excludeAssets
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
