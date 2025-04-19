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
    
    private let disposeBag = DisposeBag()
    
    struct Input {
        let viewDidLoad: Signal<Void>
        let titleTextChanged: Signal<String>
        let datePickerTapped: Signal<Void>
        let saveButtonTapped: Signal<Void>
    }
    
    struct Output {
        let record: Driver<Record>
        let titleText: Signal<String>
        let startDate: Signal<Date>
        let datePickerPresented: Signal<Date>
        let isSaveButtonEnabled: Driver<Bool>
        let dismiss: Signal<Record>
    }
    
    let record = BehaviorRelay<Record>(value: .initialValue)
    let titleText = BehaviorRelay<String>(value: "")
    let startDate = BehaviorRelay<Date>(value: .now)
    let datePickerPresented = PublishRelay<Date>()
    let isSaveButtonEnabled = BehaviorRelay<Bool>(value: true)
    let dismiss = PublishRelay<Record>()
}

// MARK: - Transform

extension MomentEditViewModel {
    
    func transform(_ input: Input) -> Output {
        input.titleTextChanged
            .emit(to: titleText)
            .disposed(by: disposeBag)
        
        input.titleTextChanged
            .map { !$0.isEmpty }
            .emit(to: isSaveButtonEnabled)
            .disposed(by: disposeBag)
        
        input.datePickerTapped
            .withUnretained(self)
            .map { owner, _ in owner.startDate.value }
            .emit(to: datePickerPresented)
            .disposed(by: disposeBag)
        
        input.saveButtonTapped
            .withUnretained(self)
            .emit { owner, _ in
                let title = owner.titleText.value.isEmpty ? owner.record.value.title : owner.titleText.value
                owner.dismiss.accept(Record(title: title, trackingStartDate: owner.startDate.value))
            }
            .disposed(by: disposeBag)
        
        return Output(
            record: record.asDriver(),
            titleText: titleText.asSignal(onErrorJustReturn: ""),
            startDate: startDate.asSignal(onErrorSignalWith: .never()),
            datePickerPresented: datePickerPresented.asSignal(onErrorSignalWith: .never()),
            isSaveButtonEnabled: isSaveButtonEnabled.asDriver(),
            dismiss: dismiss.asSignal()
        )
    }
}
