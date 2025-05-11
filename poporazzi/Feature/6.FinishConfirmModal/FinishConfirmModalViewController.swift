//
//  FinishConfirmModalViewController.swift
//  poporazzi
//
//  Created by 김민준 on 5/11/25.
//

import UIKit
import RxSwift
import RxCocoa

final class FinishConfirmModalViewController: ViewController {
    
    private let scene = FinishConfirmModalView()
    private let viewModel: FinishConfirmModalViewModel
    
    let disposeBag = DisposeBag()
    
    init(viewModel: FinishConfirmModalViewModel) {
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

extension FinishConfirmModalViewController {
    
    func bind() {
        let input = FinishConfirmModalViewModel.Input(
            saveAsSingleRadioButtonTapped: scene.saveAsSingleRadioButton.tapGesture.rx.event.asVoidSignal(),
            saveByDayRadioButtonTapped: scene.saveByDayRadioButton.tapGesture.rx.event.asVoidSignal(),
            finishButtonTapped: scene.finishButton.button.rx.tap.asSignal(),
            cancelButtonTapped: scene.cancelButton.button.rx.tap.asSignal()
        )
        let output = viewModel.transform(input)
        
        output.saveOption
            .bind(with: self) { owner, saveOption in
                switch saveOption {
                case .none: owner.scene.action(.updateRadioState(.none))
                case .saveAsSingle: owner.scene.action(.updateRadioState(.saveAsSingle))
                case .saveByDay: owner.scene.action(.updateRadioState(.saveByDay))
                }
            }
            .disposed(by: disposeBag)
        
        output.alertPresented
            .bind(with: self) { owner, alert in
                owner.showAlert(alert)
            }
            .disposed(by: disposeBag)
    }
}
