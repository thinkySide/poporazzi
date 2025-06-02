//
//  RecordEditViewController.swift
//  poporazzi
//
//  Created by 김민준 on 4/17/25.
//

import UIKit
import RxSwift
import RxCocoa

final class RecordEditViewController: ViewController {
    
    private let scene = RecordEditView()
    private let viewModel: RecordEditViewModel
    
    let disposeBag = DisposeBag()
    
    init(viewModel: RecordEditViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = scene
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
    
    deinit {
        Log.print(#file, .deinit)
    }
}

// MARK: - Binding

extension RecordEditViewController {
    
    func bind() {
        let input = RecordEditViewModel.Input(
            viewDidLoad: .just(()),
            titleTextChanged: scene.titleTextField.textField.rx.text.orEmpty.asSignal(onErrorJustReturn: ""),
            startDatePickerTapped: scene.startDatePicker.tapGesture.rx.event.asVoidSignal(),
            endDatePickerTapped: scene.endDatePicker.tapGesture.rx.event.asVoidSignal(),
            allSaveChoiceChipTapped: scene.allChoiceChip.button.rx.tap.asSignal(),
            photoChoiceChipTapped: scene.photoChoiceChip.button.rx.tap.asSignal(),
            videoChoiceChipTapped: scene.videoChoiceChip.button.rx.tap.asSignal(),
            selfShootingOptionCheckBoxTapped: scene.selfShootingOptionCheckBox.tapGesture.rx.event.asVoidSignal(),
            downloadOptionCheckBox: scene.downloadOptionCheckBox.tapGesture.rx.event.asVoidSignal(),
            screenshotOptionCheckBox: scene.screenshotOptionCheckBox.tapGesture.rx.event.asVoidSignal(),
            backButtonTapped: scene.backButton.button.rx.tap.asSignal(),
            saveButtonTapped: scene.saveButton.button.rx.tap.asSignal()
        )
        let output = viewModel.transform(input)
        
        output.album
            .bind(with: self) { owner, record in
                owner.scene.titleTextField.action(.updateText(record.title))
                owner.scene.titleTextField.action(.updatePlaceholder(record.title))
            }
            .disposed(by: disposeBag)
        
        output.startDate
            .bind(with: self) { owner, startDate in
                owner.scene.startDatePicker.action(.updateDateLabel(startDate.startDateFullFormat))
            }
            .disposed(by: disposeBag)
        
        output.endDate
            .bind(with: self) { owner, endDate in
                if let endDate = endDate {
                    owner.scene.endDatePicker.action(.updateDateLabel(endDate.endDateFullFormat))
                } else {
                    owner.scene.endDatePicker.action(.updateDateLabel("기록 종료 시 까지"))
                }
            }
            .disposed(by: disposeBag)
        
        output.isSaveButtonEnabled
            .bind(with: self) { owner, isValid in
                owner.scene.action(.toggleSaveButton(isValid))
            }
            .disposed(by: disposeBag)

        output.isValidCheckBox
            .bind(with: self) { owner, isValid in
                owner.scene.action(.toggleFilterOptionsFormLabel(isValid))
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
        
        output.mediaFetchOption
            .bind(with: self) { owner, fetchOption in
                owner.scene.action(.updateMediaFetchOption(fetchOption))
            }
            .disposed(by: disposeBag)
        
        output.mediaFilterOption
            .bind(with: self) { owner, filterOption in
                owner.scene.action(.updateMediaFilterOption(filterOption))
            }
            .disposed(by: disposeBag)
        
        viewModel.navigation
            .bind(with: self) { owner, path in
                owner.scene.titleTextField.action(.dismissKeyboard)
            }
            .disposed(by: disposeBag)
    }
}
