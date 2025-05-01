//
//  TitleInputViewController.swift
//  poporazzi
//
//  Created by 김민준 on 4/4/25.
//

import UIKit
import RxSwift
import RxCocoa

final class TitleInputViewController: ViewController {
    
    private let scene = TitleInputView()
    private let viewModel: TitleInputViewModel
    private let disposeBag = DisposeBag()
    
    init(viewModel: TitleInputViewModel) {
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scene.titleTextField.action(.presentKeyboard)
    }
    
    deinit {
        Log.print(#file, .deinit)
    }
}

// MARK: - Binding

extension TitleInputViewController {
    
    func bind() {
        let input = TitleInputViewModel.Input(
            titleTextChanged: scene.titleTextField.textField.rx.text.orEmpty.asSignal(onErrorJustReturn: ""),
            startButtonTapped: scene.actionButton.button.rx.tap.asSignal()
        )
        let output = viewModel.transform(input)
        
        output.isStartButtonEnabled
            .bind(with: self) { owner, isEnabled in
                owner.scene.actionButton.action(.toggleEnabled(isEnabled))
            }
            .disposed(by: disposeBag)
        
        scene.titleTextField.textField.rx.text
            .subscribe(with: self) { owner, _ in
                owner.scene.titleTextField.action(.toggleLine)
            }
            .disposed(by: disposeBag)
        
        viewModel.navigation
            .bind(with: self) { owner, path in
                switch path {
                case .pushRecord:
                    owner.scene.titleTextField.textField.text = ""
                }
            }
            .disposed(by: disposeBag)
    }
}
