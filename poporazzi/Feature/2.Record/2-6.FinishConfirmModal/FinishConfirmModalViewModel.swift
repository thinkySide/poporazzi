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
    @Dependency(\.userNotificationService) private var userNotificationService
    
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

extension FinishConfirmModalViewModel {
    
    struct Input {
        let saveAsSingleRadioButtonTapped: Signal<Void>
        let saveByDayRadioButtonTapped: Signal<Void>
        let finishButtonTapped: Signal<Void>
        let cancelButtonTapped: Signal<Void>
    }
    
    struct Output {
        let record: BehaviorRelay<Record>
        let sectionMediaList: BehaviorRelay<SectionMediaList>
        let saveOption = BehaviorRelay<RecordSaveOption>(value: .saveAsSingle)
        let toggleLoading = BehaviorRelay<Bool>(value: false)
    }
    
    enum Navigation {
        case dismiss
        case finishRecord
    }
}

// MARK: - Transform

extension FinishConfirmModalViewModel {
    
    func transform(_ input: Input) -> Output {
        input.saveAsSingleRadioButtonTapped
            .emit(with: self) { owner, _ in
                owner.output.saveOption.accept(.saveAsSingle)
                HapticManager.impact(style: .soft)
            }
            .disposed(by: disposeBag)
        
        input.saveByDayRadioButtonTapped
            .emit(with: self) { owner, _ in
                owner.output.saveOption.accept(.saveByDay)
                HapticManager.impact(style: .soft)
            }
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
                    
                default:
                    owner.navigation.accept(.finishRecord)
                    owner.finishRecord()
                }
            }
            .disposed(by: disposeBag)
        
        input.cancelButtonTapped
            .emit(with: self) { owner, _ in
                owner.navigation.accept(.dismiss)
            }
            .disposed(by: disposeBag)
        
        return output
    }
}

// MARK: - Helper

extension FinishConfirmModalViewModel {
    
    /// 기록을 종료합니다.
    private func finishRecord() {
        navigation.accept(.finishRecord)
        liveActivityService.stop()
        userNotificationService.cancelAllNotification()
        HapticManager.notification(type: .success)
        UserDefaultsService.trackingAlbumId = ""
    }
}

// MARK: - Album Logic

extension FinishConfirmModalViewModel {
    
    /// 하나로 앨범을 저장합니다.
    private func saveAlbumAsSingle() -> Observable<Void> {
        photoKitService.saveAlbumAsSingle(
            title: output.record.value.title,
            sectionMediaList: output.sectionMediaList.value
        )
    }
    
    /// 일차별로 앨범을 저장합니다.
    private func saveAlubmByDay() -> Observable<Void> {
        photoKitService.saveAlubmByDay(
            title: output.record.value.title,
            sectionMediaList: output.sectionMediaList.value
        )
    }
}
