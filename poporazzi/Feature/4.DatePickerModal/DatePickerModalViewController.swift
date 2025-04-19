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
    
    private weak var coordinator: AppCoordinator?
    private let viewModel: DatePickerModalViewModel
    
    private let scene = DatePickerModalView()
    private let disposeBag = DisposeBag()
    
    init(coordinator: AppCoordinator? = nil, viewModel: DatePickerModalViewModel) {
        self.coordinator = coordinator
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
}

// MARK: - Binding

extension DatePickerModalViewController {
    
    func bind() {
        let input = DatePickerModalViewModel.Input(
            datePickerChanged: scene.datePicker.rx.value.changed.asSignal(),
            confirmButtonTapped: scene.confirmButton.button.rx.tap.asSignal()
        )
        let output = viewModel.transform(input)
        
        output.selectedDate
            .drive(with: self) { owner, date in
                owner.scene.action(.updateSelecteDate(date))
            }
            .disposed(by: disposeBag)
        
        output.confirm
            .emit(with: self) { owner, date in
                owner.coordinator?.momentEditViewModel.startDate.accept(date)
                owner.coordinator?.dismiss()
            }
            .disposed(by: disposeBag)
    }
}
