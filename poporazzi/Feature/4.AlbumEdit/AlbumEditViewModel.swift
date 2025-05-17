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
    
    @Dependency(\.persistenceService) private var persistenceDataService
    
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
        let endDatePickerTapped: Signal<Void>
        
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
        let album: BehaviorRelay<Album>
        
        let titleText: BehaviorRelay<String>
        let startDate: BehaviorRelay<Date>
        let endDate: BehaviorRelay<Date?>
        
        let mediaFetchOption: BehaviorRelay<MediaFetchOption>
        let mediaFilterOption: BehaviorRelay<MediaFilterOption>
        
        let isSaveButtonEnabled = BehaviorRelay<Bool>(value: true)
    }
    
    enum Navigation {
        case presentStartDatePicker(startDate: Date, endDate: Date?)
        case presentEndDatePicker(startDate: Date, endDate: Date?)
        case pop
        case dismissWithUpdate(Album)
    }
    
    enum Delegate {
        case startDateDidChanged(Date)
        case endDateDidChanged(Date?)
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
                let endDate = owner.output.endDate.value
                owner.navigation.accept(.presentStartDatePicker(startDate: startDate, endDate: endDate))
            }
            .disposed(by: disposeBag)
        
        input.endDatePickerTapped
            .emit(with: self) { owner, _ in
                let startDate = owner.output.startDate.value
                let endDate = owner.output.endDate.value
                owner.navigation.accept(.presentEndDatePicker(startDate: startDate, endDate: endDate))
            }
            .disposed(by: disposeBag)
        
        input.allSaveChoiceChipTapped
            .emit(with: self) { owner, _ in
                owner.output.mediaFetchOption.accept(.all)
                owner.output.isSaveButtonEnabled.accept(owner.isValidCheckBox())
                HapticManager.impact(style: .soft)
            }
            .disposed(by: disposeBag)
        
        input.photoChoiceChipTapped
            .emit(with: self) { owner, _ in
                owner.output.mediaFetchOption.accept(.photo)
                owner.output.isSaveButtonEnabled.accept(owner.isValidCheckBox())
                HapticManager.impact(style: .soft)
            }
            .disposed(by: disposeBag)
        input.videoChoiceChipTapped
            .emit(with: self) { owner, _ in
                owner.output.mediaFetchOption.accept(.video)
                owner.output.isSaveButtonEnabled.accept(owner.isValidCheckBox())
                HapticManager.impact(style: .soft)
            }
            .disposed(by: disposeBag)
        
        input.selfShootingOptionCheckBoxTapped
            .emit(with: self) { owner, _ in
                var filter = owner.output.mediaFilterOption.value
                filter.isContainSelfShooting.toggle()
                owner.output.mediaFilterOption.accept(filter)
                owner.output.isSaveButtonEnabled.accept(owner.isValidCheckBox())
                if filter.isContainSelfShooting { HapticManager.impact(style: .soft) }
            }
            .disposed(by: disposeBag)
        
        input.downloadOptionCheckBox
            .emit(with: self) { owner, _ in
                var filter = owner.output.mediaFilterOption.value
                filter.isContainDownload.toggle()
                owner.output.mediaFilterOption.accept(filter)
                owner.output.isSaveButtonEnabled.accept(owner.isValidCheckBox())
                if filter.isContainDownload { HapticManager.impact(style: .soft) }
            }
            .disposed(by: disposeBag)
        
        input.screenshotOptionCheckBox
            .emit(with: self) { owner, _ in
                var filter = owner.output.mediaFilterOption.value
                filter.isContainScreenshot.toggle()
                owner.output.mediaFilterOption.accept(filter)
                owner.output.isSaveButtonEnabled.accept(owner.isValidCheckBox())
                if filter.isContainScreenshot { HapticManager.impact(style: .soft) }
            }
            .disposed(by: disposeBag)
        
        input.backButtonTapped
            .emit(with: self) { owner, _ in
                owner.navigation.accept(.pop)
            }
            .disposed(by: disposeBag)
        
        input.saveButtonTapped
            .emit(with: self) { owner, _ in
                let currentTitle = owner.output.titleText.value
                let oldAlbum = owner.output.album.value
                let albumTitle = currentTitle.isEmpty ? oldAlbum.title : currentTitle
                
                let newAlbum = Album(
                    id: oldAlbum.id,
                    title: albumTitle,
                    startDate: owner.output.startDate.value,
                    endDate: owner.output.endDate.value,
                    excludeMediaList: oldAlbum.excludeMediaList,
                    mediaFetchOption: owner.output.mediaFetchOption.value,
                    mediaFilterOption: owner.output.mediaFilterOption.value
                )
                
                owner.navigation.accept(.dismissWithUpdate(newAlbum))
                
                HapticManager.notification(type: .success)
                
                owner.persistenceDataService.updateAlbum(to: newAlbum)
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

// MARK: - CheckBox

extension AlbumEditViewModel {
    
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
