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
    
    private let screen = MomentTitleInputView()
    private let viewModel = MomentTitleInputViewModel()
    
    var disposeBag = DisposeBag()
    
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
            .bind { title in
                print("앨범 제목: \(title)")
            }
            .disposed(by: disposeBag)
    }
}
