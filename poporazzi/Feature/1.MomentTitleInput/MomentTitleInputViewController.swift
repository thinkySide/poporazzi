//
//  MomentTitleInputViewController.swift
//  poporazzi
//
//  Created by 김민준 on 4/4/25.
//

import UIKit
import RxSwift
import RxCocoa

final class MomentTitleInputViewController: BaseViewController {
    
    private let viewModel: MomentTitleInputViewModel
    
    private let scene = MomentTitleInputView()
    private let disposeBag = DisposeBag()
    
    init(coordinator: AppCoordinator, viewModel: MomentTitleInputViewModel) {
        self.viewModel = viewModel
        super.init(coordinator: coordinator)
    }
    
    override func loadView() {
        view = scene
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scene.titleTextField.action(.presentKeyboard)
    }
}

// MARK: - Binding

extension MomentTitleInputViewController {
    
    func bind() {
        let input = MomentTitleInputViewModel.Input(
            titleTextChanged: scene.titleTextField.textField.rx.text.orEmpty.asSignal(onErrorJustReturn: ""),
            startButtonTapped:scene.actionButton.button.rx.tap.asSignal()
        )
        let output = viewModel.transform(input)
        
        scene.titleTextField.textField.rx.text
            .subscribe(with: self) { owner, _ in
                owner.scene.titleTextField.action(.toggleLine)
            }
            .disposed(by: disposeBag)
        
        output.isStartButtonEnabled
            .emit(with: self) { owner, isEnabled in
                owner.scene.actionButton.action(.toggleEnabled(isEnabled))
            }
            .disposed(by: disposeBag)
        
        output.didNavigateToRecord
            .emit(with: self) { owner, record in
                owner.scene.titleTextField.textField.text = ""
                owner.coordinator?.pushMomentRecord(record: record)
            }
            .disposed(by: disposeBag)
    }
}
