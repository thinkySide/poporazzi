//
//  DateInputViewController.swift
//  poporazzi
//
//  Created by 김민준 on 5/13/25.
//

import UIKit
import RxSwift
import RxCocoa

final class DateInputViewController: ViewController {
    
    private let scene = DateInputView()
    private let viewModel: DateInputViewModel
    
    let disposeBag = DisposeBag()
    
    init(viewModel: DateInputViewModel) {
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

extension DateInputViewController {
    
    func bind() {
        let input = DateInputViewModel.Input(
            backButtonTapped: scene.backButton.button.rx.tap.asSignal(),
            startDatePickerTapped: scene.startDatePicker.tapGesture.rx.event.asVoidSignal(),
            endDatePickerTapped: scene.endDatePicker.tapGesture.rx.event.asVoidSignal(),
            startButtonTapped: scene.startButton.button.rx.tap.asSignal()
        )
        let output = viewModel.transform(input)
        
        output.startDate
            .bind(with: self) { owner, startDate in
                if let startDate = startDate {
                    owner.scene.startDatePicker.action(.updateDateLabel(startDate.startDateFullFormat))
                } else {
                    owner.scene.startDatePicker.action(.updateDateLabel(String(localized: "기록 시작 부터")))
                }
            }
            .disposed(by: disposeBag)
        
        output.endDate
            .bind(with: self) { owner, endDate in
                if let endDate = endDate {
                    owner.scene.endDatePicker.action(.updateDateLabel(endDate.endDateFullFormat))
                } else {
                    owner.scene.endDatePicker.action(.updateDateLabel(String(localized: "기록 종료 까지")))
                }
            }
            .disposed(by: disposeBag)
    }
}
