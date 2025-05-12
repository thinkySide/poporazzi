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
            containScreenshotChanged: scene.containScreenshotSwitch.controlSwitch.rx.isOn.asSignal(onErrorJustReturn: false),
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
                owner.scene.action(.updateTitleTextFieldSubLabel)
            }
            .disposed(by: disposeBag)
        
        viewModel.navigation
            .bind(with: self) { owner, path in
                switch path {
                case .pushRecord:
                    Task {
                        try await Task.sleep(for: .seconds(1))
                        await MainActor.run {
                            owner.scene.titleTextField.textField.text = ""
                            owner.scene.containScreenshotSwitch.controlSwitch.isOn = false
                        }
                    }
                }
            }
            .disposed(by: disposeBag)
        
        output.alertPresented
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, alert in
                owner.showAlert(alert)
            }
            .disposed(by: disposeBag)
    }
}
