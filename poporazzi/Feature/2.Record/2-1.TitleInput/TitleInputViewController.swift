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
    
    let disposeBag = DisposeBag()
    
    init(viewModel: TitleInputViewModel) {
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

extension TitleInputViewController {
    
    func bind() {
        let input = TitleInputViewModel.Input(
            titleTextChanged: scene.titleTextField.textField.rx.text.orEmpty.asSignal(onErrorJustReturn: ""),
            nextButtonTapped: scene.nextButton.button.rx.tap.asSignal()
        )
        let output = viewModel.transform(input)
        
        output.isNextButtonEnabled
            .bind(with: self) { owner, isEnabled in
                owner.scene.nextButton.action(.toggleEnabled(isEnabled))
            }
            .disposed(by: disposeBag)
        
        scene.titleTextField.textField.rx.text
            .subscribe(with: self) { owner, _ in
                owner.scene.titleTextField.action(.toggleLine)
            }
            .disposed(by: disposeBag)
    }
}
