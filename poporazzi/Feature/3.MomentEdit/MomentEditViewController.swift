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
    private let viewModel = MomentEditViewModel()
    private let disposeBag = DisposeBag()
    
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
            }
            .disposed(by: disposeBag)
        
        ouput.dismiss
            .emit(with: self) { owner, _ in
                owner.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
        
        scene.backButton.button.rx.tap
            .subscribe(with: self) { owner, _ in
                owner.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
    }
}
