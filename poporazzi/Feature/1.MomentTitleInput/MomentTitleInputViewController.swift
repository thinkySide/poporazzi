//
//  MomentTitleInputViewController.swift
//  poporazzi
//
//  Created by 김민준 on 4/4/25.
//

import UIKit
import RxSwift
import RxCocoa

final class MomentTitleInputViewController: ViewController {
    
    private let scene = MomentTitleInputView()
    private let viewModel = MomentTitleInputViewModel()
    private let disposeBag = DisposeBag()
    
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
        
        output.isStartButtonEnabled
            .emit(with: self) { owner, isEnabled in
                owner.scene.actionButton.action(.toggleEnabled(isEnabled))
            }
            .disposed(by: disposeBag)
        
        output.didNavigateToRecord
            .emit(with: self) { owner, _ in
                owner.scene.titleTextField.textField.text = ""
                owner.presentMomentRecord()
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - Navigation

extension MomentTitleInputViewController {
    
    /// 기록 화면을 출력합니다.
    private func presentMomentRecord() {
        let momentRecordVC = MomentRecordViewController()
        momentRecordVC.modalPresentationStyle = .fullScreen
        momentRecordVC.modalTransitionStyle = .crossDissolve
        self.present(momentRecordVC, animated: true)
    }
}
