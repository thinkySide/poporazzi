//
//  DatePickerModalViewController.swift
//  poporazzi
//
//  Created by 김민준 on 4/18/25.
//

import UIKit
import RxSwift
import RxCocoa

final class DatePickerModalViewController: ViewController {
    
    private let scene = DatePickerModalView()
    private let viewModel = DatePickerModalViewModel()
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

extension DatePickerModalViewController {
    
    func bind() {
        let input = DatePickerModalViewModel.Input(
            viewDidLoad: .just(()),
            datePickerChanged: scene.datePicker.rx.value.changed.asSignal()
        )
        let output = viewModel.transform(input)
        
        output.selectedDate
            .drive(with: self) { owner, date in
                owner.scene.datePicker.date = date
            }
            .disposed(by: disposeBag)
        
        scene.confirmButton.button.rx.tap
            .subscribe(with: self) { owner, _ in
                owner.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
    }
}
