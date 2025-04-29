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
        setupGesture()
        bind()
    }
}

// MARK: - Binding

extension MomentEditViewController {
    
    func bind() {
        let action = MomentEditViewModel.Action(
            viewDidLoad: .just(()),
            titleTextChanged: scene.titleTextField.textField.rx.text.orEmpty.asSignal(onErrorJustReturn: ""),
            saveButtonTapped: scene.saveButton.button.rx.tap.asSignal()
        )
        let state = viewModel.transform(action)
        
        state.record
            .bind(with: self) { owner, record in
                owner.scene.titleTextField.action(.updateText(record.title))
                owner.scene.titleTextField.action(.updatePlaceholder(record.title))
                owner.scene.startDatePicker.action(.updateDate(record.trackingStartDate))
            }
            .disposed(by: disposeBag)
        
        state.isSaveButtonEnabled
            .bind(with: self) { owner, isEnabled in
                owner.scene.saveButton.action(.toggleDisabled(!isEnabled))
            }
            .disposed(by: disposeBag)
        
        scene.titleTextField.textField.rx.text
            .subscribe(with: self) { owner, title in
                owner.scene.titleTextField.action(.toggleLine)
            }
            .disposed(by: disposeBag)
        
        scene.startDatePicker.tapGesture.rx.event
            .subscribe(with: self) { owner, _ in
                // owner.presentDatePickerModal()
            }
            .disposed(by: disposeBag)
        
        scene.backButton.button.rx.tap
            .subscribe(with: self) { owner, _ in
                owner.dismiss(animated: true)
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

// MARK: - Navigation

extension MomentEditViewController {
    
    /// 날짜 선택 모달을 출력합니다.
//    private func presentDatePickerModal() {
//        let datePickerVC = DatePickerModalViewController()
//        datePickerVC.sheetPresentationController?.preferredCornerRadius = 20
//        datePickerVC.sheetPresentationController?.detents = [.custom(resolver: { _ in 300 })]
//        datePickerVC.sheetPresentationController?.prefersGrabberVisible = true
//        self.present(datePickerVC, animated: true)
//    }
}
