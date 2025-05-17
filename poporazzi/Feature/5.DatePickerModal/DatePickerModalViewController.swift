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
    
    private let scene: DatePickerModalView
    private let viewModel: DatePickerModalViewModel
    
    let disposeBag = DisposeBag()
    let viewWillAppear = PublishRelay<Void>()
    
    init(viewModel: DatePickerModalViewModel, variation: DatePickerModalView.Variation) {
        self.viewModel = viewModel
        self.scene = DatePickerModalView(variation: variation)
        super.init(nibName: nil, bundle: nil)
        self.sheetPresentationController?.detents = [.custom(resolver: { _ in variation.sheetHeight })]
    }
    
    override func loadView() {
        view = scene
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewWillAppear.accept(())
    }
    
    deinit {
        Log.print(#file, .deinit)
    }
}

// MARK: - Binding

extension DatePickerModalViewController {
    
    func bind() {
        let action = DatePickerModalViewModel.Input(
            viewWillAppear: viewWillAppear.asSignal(),
            datePickerChanged: scene.datePicker.rx.value.changed.asSignal(),
            confirmButtonTapped: scene.confirmButton.button.rx.tap.asSignal()
        )
        let state = viewModel.transform(action)
        
        state.setupSelectableStartDateRange
            .bind(with: self) { owner, date in
                owner.scene.action(.setupSelectableStartDateRange(endDate: date))
            }
            .disposed(by: disposeBag)
        
        state.setupSelectableEndDateRange
            .bind(with: self) { owner, date in
                owner.scene.action(.setupSelectableEndDateRange(startDate: date))
            }
            .disposed(by: disposeBag)
    }
}
