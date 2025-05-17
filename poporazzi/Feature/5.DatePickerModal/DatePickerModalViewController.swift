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
    
    deinit {
        Log.print(#file, .deinit)
    }
}

// MARK: - Binding

extension DatePickerModalViewController {
    
    func bind() {
        let action = DatePickerModalViewModel.Input(
            viewDidLoad: .just(()),
            datePickerChanged: scene.datePicker.rx.value.changed.asSignal(),
            confirmButtonTapped: scene.confirmButton.button.rx.tap.asSignal()
        )
        let state = viewModel.transform(action)
        
//        state.selectedDate
//            .bind(with: self) { owner, date in
//                owner.scene.datePicker.date = date ?? .now
//            }
//            .disposed(by: disposeBag)
    }
}
