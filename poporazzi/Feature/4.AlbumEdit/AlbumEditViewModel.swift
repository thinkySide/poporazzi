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
        
        let allSaveChoiceChipTapped: Signal<Void>
        let photoChoiceChipTapped: Signal<Void>
        let videoChoiceChipTapped: Signal<Void>
        
        let selfShootingOptionCheckBoxTapped: Signal<Void>
        let downloadOptionCheckBox: Signal<Void>
        let screenshotOptionCheckBox: Signal<Void>
        
        let backButtonTapped: Signal<Void>
        let saveButtonTapped: Signal<Void>
    }
    
    struct Output {
        let record: BehaviorRelay<Album>
        let titleText: BehaviorRelay<String>
        let startDate: BehaviorRelay<Date>
        
        let mediaFetchType: BehaviorRelay<MediaFetchType>
        let mediaFetchDetailType: BehaviorRelay<[MediaDetialFetchType]>
        
        let isSaveButtonEnabled = BehaviorRelay<Bool>(value: true)
    }
    
    enum Navigation {
        case presentStartDatePicker(Date)
        case dismiss
        case dismissWithUpdate(Album, MediaFetchType, [MediaDetialFetchType])
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
        
        input.allSaveChoiceChipTapped
            .emit(with: self) { owner, _ in
                owner.output.mediaFetchType.accept(.all)
            }
            .disposed(by: disposeBag)
        
        input.photoChoiceChipTapped
            .emit(with: self) { owner, _ in
                owner.output.mediaFetchType.accept(.image)
            }
            .disposed(by: disposeBag)
        input.videoChoiceChipTapped
            .emit(with: self) { owner, _ in
                owner.output.mediaFetchType.accept(.video)
            }
            .disposed(by: disposeBag)
        
        input.selfShootingOptionCheckBoxTapped
            .emit(with: self) { owner, _ in
                owner.updateMediaFetchDetailType(.selfShooting)
            }
            .disposed(by: disposeBag)
        
        input.downloadOptionCheckBox
            .emit(with: self) { owner, _ in
                owner.updateMediaFetchDetailType(.download)
            }
            .disposed(by: disposeBag)
        
        input.screenshotOptionCheckBox
            .emit(with: self) { owner, _ in
                owner.updateMediaFetchDetailType(.screenshot)
            }
            .disposed(by: disposeBag)
        
        input.backButtonTapped
            .emit(with: self) { owner, _ in
                owner.navigation.accept(.dismiss)
            }
            .disposed(by: disposeBag)
        
        input.saveButtonTapped
            .emit(with: self) { owner, _ in
                let currentTitle = owner.output.titleText.value
                let albumTitle = currentTitle.isEmpty ? UserDefaultsService.albumTitle : currentTitle
                let record = (Album(title: albumTitle, trackingStartDate: owner.output.startDate.value))
                owner.navigation.accept(
                    .dismissWithUpdate(
                        owner.output.record.value,
                        owner.output.mediaFetchType.value,
                        owner.output.mediaFetchDetailType.value
                    )
                )
                HapticManager.notification(type: .success)
                UserDefaultsService.album = record
                UserDefaultsService.isContainScreenshot = true
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

// MARK: - Helper

extension AlbumEditViewModel {
    
    /// 미디어 세부 항목을 업데이트 후 상태를 업데이트합니다.
    private func updateMediaFetchDetailType(_ detailFetchType: MediaDetialFetchType) {
        var details = output.mediaFetchDetailType.value
        if details.contains(detailFetchType) {
            details.removeAll(where: { $0 == detailFetchType })
        } else {
            details.append(detailFetchType)
        }
        output.mediaFetchDetailType.accept(details)
    }
}
