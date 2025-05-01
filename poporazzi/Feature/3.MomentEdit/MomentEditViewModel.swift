//
//  MomentEditViewModel.swift
//  poporazzi
//
//  Created by 김민준 on 4/17/25.
//

import Foundation
import RxSwift
import RxCocoa

final class MomentEditViewModel: ViewModel {
    
    private let liveActivityService = LiveActivityService.shared
    
    private let disposeBag = DisposeBag()
    
    private let output: Output
    
    let navigation = PublishRelay<Navigation>()
    let delegate = PublishRelay<Delegate>()
    
    init(output: Output) {
        self.output = output
    }
}

// MARK: - Input & Output

extension MomentEditViewModel {
    
    struct Input {
        let viewDidLoad: Signal<Void>
        let titleTextChanged: Signal<String>
        let startDatePickerTapped: Signal<Void>
        let backButtonTapped: Signal<Void>
        let saveButtonTapped: Signal<Void>
    }
    
    struct Output {
        let record: BehaviorRelay<Record>
        let titleText: BehaviorRelay<String>
        let startDate: BehaviorRelay<Date>
        let totalMediaCount: BehaviorRelay<Int>
        let isSaveButtonEnabled = BehaviorRelay<Bool>(value: true)
    }
    
    enum Navigation {
        case presentStartDatePicker(Date)
        case dismiss(Record)
    }
    
    enum Delegate {
        case startDateDidChanged(Date)
    }
}

// MARK: - Transform

extension MomentEditViewModel {
    
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
                let startDate = owner.output.record.value.trackingStartDate
                owner.navigation.accept(.presentStartDatePicker(startDate))
            }
            .disposed(by: disposeBag)
        
        input.backButtonTapped
            .emit(with: self) { owner, _ in
                owner.navigation.accept(.dismiss(owner.output.record.value))
            }
            .disposed(by: disposeBag)
        
        input.saveButtonTapped
            .emit(with: self) { owner, _ in
                let currentTitle = owner.output.titleText.value
                let albumTitle = currentTitle.isEmpty ? UserDefaultsService.albumTitle : currentTitle
                let record = (Record(title: albumTitle, trackingStartDate: owner.output.startDate.value))
                owner.navigation.accept(.dismiss(record))
                owner.liveActivityService.update(
                    albumTitle: record.title,
                    startDate: record.trackingStartDate,
                    totalCount: owner.output.totalMediaCount.value
                )
                UserDefaultsService.record = record
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
