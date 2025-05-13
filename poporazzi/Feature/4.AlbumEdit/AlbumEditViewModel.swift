//
//  AlbumEditViewModel.swift
//  poporazzi
//
//  Created by 김민준 on 4/17/25.
//

import Foundation
import RxSwift
import RxCocoa

final class AlbumEditViewModel: ViewModel {
    
    let disposeBag = DisposeBag()
    
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

extension AlbumEditViewModel {
    
    struct Input {
        let viewDidLoad: Signal<Void>
        let titleTextChanged: Signal<String>
        let startDatePickerTapped: Signal<Void>
        let containScreenshotSwitchChanged: Signal<Bool>
        let backButtonTapped: Signal<Void>
        let saveButtonTapped: Signal<Void>
    }
    
    struct Output {
        let record: BehaviorRelay<Album>
        let titleText: BehaviorRelay<String>
        let startDate: BehaviorRelay<Date>
        let isContainScreenshot: BehaviorRelay<Bool>
        let isSaveButtonEnabled = BehaviorRelay<Bool>(value: true)
    }
    
    enum Navigation {
        case presentStartDatePicker(Date)
        case dismiss(Album, isContainScreenshot: Bool)
    }
    
    enum Delegate {
        case startDateDidChanged(Date)
    }
}

// MARK: - Transform

extension AlbumEditViewModel {
    
    func transform(_ input: Input) -> Output {
        input.titleTextChanged
            .emit(to: output.titleText)
            .disposed(by: disposeBag)
        
        input.titleTextChanged
            .map { !$0.isEmpty }
            .emit(to: output.isSaveButtonEnabled)
            .disposed(by: disposeBag)
        
        input.startDatePickerTapped
            .emit(with: self) { owner, _ in
                let startDate = owner.output.startDate.value
                owner.navigation.accept(.presentStartDatePicker(startDate))
            }
            .disposed(by: disposeBag)
        
        input.containScreenshotSwitchChanged
            .skip(1)
            .emit(to: output.isContainScreenshot)
            .disposed(by: disposeBag)
        
        input.backButtonTapped
            .emit(with: self) { owner, _ in
                let isContainScreenshot = UserDefaultsService.isContainScreenshot
                owner.navigation.accept(
                    .dismiss(
                        owner.output.record.value,
                        isContainScreenshot: isContainScreenshot
                    )
                )
            }
            .disposed(by: disposeBag)
        
        input.saveButtonTapped
            .emit(with: self) { owner, _ in
                let currentTitle = owner.output.titleText.value
                let albumTitle = currentTitle.isEmpty ? UserDefaultsService.albumTitle : currentTitle
                let record = (Album(title: albumTitle, trackingStartDate: owner.output.startDate.value))
                let isContainScreenshot = owner.output.isContainScreenshot.value
                owner.navigation.accept(.dismiss(record, isContainScreenshot: isContainScreenshot))
                HapticManager.notification(type: .success)
                UserDefaultsService.album = record
                UserDefaultsService.isContainScreenshot = isContainScreenshot
            }
            .disposed(by: disposeBag)
        
        delegate
            .bind(with: self) { owner, delegate in
                switch delegate {
                case .startDateDidChanged(let date):
                    owner.output.startDate.accept(date)
                }
            }
            .disposed(by: disposeBag)
        
        return output
    }
}
