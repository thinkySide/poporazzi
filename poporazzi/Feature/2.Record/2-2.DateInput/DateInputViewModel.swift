//
//  DateInputViewModel.swift
//  poporazzi
//
//  Created by 김민준 on 5/13/25.
//

import Foundation
import RxSwift
import RxCocoa

final class DateInputViewModel: ViewModel {
    
    @Dependency(\.persistenceService) var persistenceService
    @Dependency(\.photoKitService) var photoKitService
    @Dependency(\.liveActivityService) var liveActivityService
    @Dependency(\.userNotificationService) var userNotificationService
    
    private let disposeBag = DisposeBag()
    private let output: Output
    
    let navigation = PublishRelay<Navigation>()
    let delegate = PublishRelay<Delegate>()
    
    init(output: Output) {
        self.output = output
    }
    
    deinit {
        Log.print(#file, .deinit)
    }
}

// MARK: - Input & Output

extension DateInputViewModel {
    
    struct Input {
        let backButtonTapped: Signal<Void>
        let startDatePickerTapped: Signal<Void>
        let endDatePickerTapped: Signal<Void>
        let startButtonTapped: Signal<Void>
    }
    
    struct Output {
        let titleText: BehaviorRelay<String>
        let startDate = BehaviorRelay<Date?>(value: nil)
        let endDate = BehaviorRelay<Date?>(value: nil)
    }
    
    enum Navigation {
        case pop
        case presentStartDatePicker(startDate: Date, endDate: Date?)
        case presentEndDatePicker(startDate: Date, endDate: Date?)
        case startRecord(Record)
    }
    
    enum Delegate {
        case startDateDidChanged(Date)
        case endDateDidChanged(Date?)
    }
}

// MARK: - Transform

extension DateInputViewModel {
    
    func transform(_ input: Input) -> Output {
        input.backButtonTapped
            .emit(with: self) { owner, _ in
                owner.navigation.accept(.pop)
            }
            .disposed(by: disposeBag)
        
        input.startDatePickerTapped
            .emit(with: self) { owner, _ in
                let startDate = owner.output.startDate.value ?? .now
                let endDate = owner.output.endDate.value
                owner.navigation.accept(.presentStartDatePicker(startDate: startDate, endDate: endDate))
            }
            .disposed(by: disposeBag)
        
        input.endDatePickerTapped
            .emit(with: self) { owner, _ in
                let startDate = owner.output.startDate.value ?? .now
                let endDate = owner.output.endDate.value
                owner.navigation.accept(.presentEndDatePicker(startDate: startDate, endDate: endDate))
            }
            .disposed(by: disposeBag)
        
        input.startButtonTapped
            .emit(with: self) { owner, _ in
                owner.startRecord()
            }
            .disposed(by: disposeBag)
        
        delegate
            .bind(with: self) { owner, delegate in
                switch delegate {
                case .startDateDidChanged(let date):
                    owner.output.startDate.accept(date)
                    
                case .endDateDidChanged(let date):
                    owner.output.endDate.accept(date)
                }
            }
            .disposed(by: disposeBag)
        
        return output
    }
}

// MARK: - Helper

extension DateInputViewModel {
    
    /// 기록을 시작합니다.
    private func startRecord() {
        let album = Record(
            title: output.titleText.value,
            startDate: output.startDate.value ?? .now,
            endDate: output.endDate.value,
            mediaFetchOption: .all,
            mediaFilterOption: .init()
        )
        
        navigation.accept(.startRecord(album))
        liveActivityService.start(to: album)
        HapticManager.notification(type: .success)
        
        try? persistenceService.createAlbum(from: album)
        UserDefaultsService.trackingAlbumId = album.id
        
        userNotificationService.checkAuth()
            .bind(with: self) { owner, isAuth in
                if isAuth {
                    owner.registerNotification()
                } else {
                    owner.userNotificationService.requestAuth()
                        .bind { isRequestAuth in
                            if isRequestAuth {
                                owner.registerNotification()
                            }
                        }
                        .disposed(by: owner.disposeBag)
                }
            }
            .disposed(by: disposeBag)
    }
    
    /// 시작 날짜를 기준으로 Notification을 등록합니다.
    private func registerNotification() {
        if let startDate = output.startDate.value {
            userNotificationService.registerNotification(
                title: "\(output.titleText.value) 앨범 기록 시작 📸",
                body: "지금부터 촬영한 모든 항목을 기록할게요!",
                triggerDate: startDate
            )
        }
    }
}
