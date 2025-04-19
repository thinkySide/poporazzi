//
//  MomentEditViewController.swift
//  poporazzi
//
//  Created by 김민준 on 4/17/25.
//

import UIKit
import RxSwift
import RxCocoa

final class MomentEditViewController: ViewController {
    
    private weak var coordinator: AppCoordinator?
    private let viewModel: MomentEditViewModel
    
    private let scene = MomentEditView()
    private let disposeBag = DisposeBag()
    
    init(coordinator: AppCoordinator? = nil, viewModel: MomentEditViewModel) {
        self.coordinator = coordinator
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    override func loadView() {
        view = scene
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGesture()
        bind()
    }
}

// MARK: - Binding

extension MomentEditViewController {
    
    func bind() {
        let input = MomentEditViewModel.Input(
            viewDidLoad: .just(()),
            titleTextChanged: scene.titleTextField.textField.rx.text.orEmpty.asSignal(onErrorJustReturn: ""),
            datePickerTapped: scene.startDatePicker.tapGesture.rx.event.map { _ in }.asSignal(onErrorSignalWith: .never()),
            saveButtonTapped: scene.saveButton.button.rx.tap.asSignal()
        )
        let ouput = viewModel.transform(input)
        
        scene.titleTextField.textField.rx.text
            .subscribe(with: self) { owner, title in
                owner.scene.titleTextField.action(.toggleLine)
            }
            .disposed(by: disposeBag)
        
        ouput.record
            .drive(with: self) { owner, record in
                owner.scene.titleTextField.action(.updateText(record.title))
                owner.scene.titleTextField.action(.updatePlaceholder(record.title))
                owner.scene.startDatePicker.action(.updateDate(record.trackingStartDate))
            }
            .disposed(by: disposeBag)
        
        ouput.startDate
            .emit(with: self) { owner, date in
                owner.scene.startDatePicker.action(.updateDate(date))
            }
            .disposed(by: disposeBag)
        
        ouput.isSaveButtonEnabled
            .drive(with: self) { owner, isEnabled in
                owner.scene.saveButton.action(.toggleDisabled(!isEnabled))
            }
            .disposed(by: disposeBag)
        
        ouput.datePickerPresented
            .emit(with: self) { owner, date in
                owner.coordinator?.presentDatePickerModal(selectedDate: date)
            }
            .disposed(by: disposeBag)
        
        ouput.dismiss
            .emit(with: self) { owner, record in
                owner.coordinator?.momentRecordViewModel.record.accept(record)
                owner.coordinator?.dismiss()
            }
            .disposed(by: disposeBag)
        
        scene.backButton.button.rx.tap
            .subscribe(with: self) { owner, _ in
                owner.coordinator?.dismiss()
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - Gesture

extension MomentEditViewController {
    
    private func setupGesture() {
        scene.startDatePicker.addGestureRecognizer(scene.startDatePicker.tapGesture)
    }
}
