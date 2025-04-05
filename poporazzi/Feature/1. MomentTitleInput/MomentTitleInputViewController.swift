//
//  MomentTitleInputViewController.swift
//  poporazzi
//
//  Created by 김민준 on 4/4/25.
//

import UIKit
import RxSwift
import RxCocoa

final class MomentTitleInputViewController: UIViewController {
    
    private let screen = MomentTitleInputView()
    private let viewModel = MomentTitleInputViewModel()
    private var disposeBag = DisposeBag()
    
    override func loadView() {
        view = screen
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
}

// MARK: - Binding

extension MomentTitleInputViewController {
    
    func bind() {
        let output = viewModel.transform(
            MomentTitleInputViewModel.Input(
                titleTextFieldDidChange: screen.titleTextField.textField
                    .rx.text.orEmpty.asObservable(),
                actionButtonTapped: screen.actionButton.button
                    .rx.tap.asObservable()
            )
        )
        
        output.actionButtonIsEnabled
            .bind(with: self, onNext: { owner, isEnabled in
                owner.screen.actionButton.action(.toggleEnabled(isEnabled))
            })
            .disposed(by: disposeBag)
            
        
        output.navigateToRecordView
            .bind { _ in
                print("액션 버튼 탭")
            }
            .disposed(by: disposeBag)
    }
}
