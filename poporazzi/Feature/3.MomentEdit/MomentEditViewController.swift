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
    
    private let scene = MomentEditView()
    private let viewModel: MomentEditViewModel
    private let disposeBag = DisposeBag()
    
    init(viewModel: MomentEditViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    override func loadView() {
        view = scene
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
}

// MARK: - Binding

extension MomentEditViewController {
    
    func bind() {
        let input = MomentEditViewModel.Input(
            viewDidLoad: .just(()),
            titleTextChanged: scene.titleTextField.textField.rx.text.orEmpty.asSignal(onErrorJustReturn: ""),
            startDatePickerTapped: scene.startDatePicker.tapGesture.rx.event.asVoidSignal(),
            backButtonTapped: scene.backButton.button.rx.tap.asSignal(),
            saveButtonTapped: scene.saveButton.button.rx.tap.asSignal()
        )
        let output = viewModel.transform(input)
        
        output.record
            .bind(with: self) { owner, record in
                owner.scene.titleTextField.action(.updateText(record.title))
                owner.scene.titleTextField.action(.updatePlaceholder(record.title))
                owner.scene.startDatePicker.action(.updateDate(record.trackingStartDate))
            }
            .disposed(by: disposeBag)
        
        output.startDate
            .bind(with: self) { owner, date in
                owner.scene.startDatePicker.action(.updateDate(date))
            }
            .disposed(by: disposeBag)
        
        output.isSaveButtonEnabled
            .bind(with: self) { owner, isEnabled in
                owner.scene.saveButton.action(.toggleDisabled(!isEnabled))
            }
            .disposed(by: disposeBag)
        
        scene.titleTextField.textField.rx.text
            .subscribe(with: self) { owner, title in
                owner.scene.titleTextField.action(.toggleLine)
            }
            .disposed(by: disposeBag)
        
        scene.tapGesture.rx.event
            .subscribe(with: self) { owner, _ in
                owner.scene.titleTextField.action(.dismissKeyboard)
            }
            .disposed(by: disposeBag)
        
        viewModel.navigation
            .bind(with: self) { owner, path in
                owner.scene.titleTextField.action(.dismissKeyboard)
            }
            .disposed(by: disposeBag)
    }
}
