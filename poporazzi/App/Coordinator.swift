//
//  Coordinator.swift
//  poporazzi
//
//  Created by 김민준 on 4/28/25.
//

import UIKit
import RxSwift
import RxCocoa

final class Coordinator {
    
    private var window: UIWindow?
    private var navigationController = UINavigationController()
    private let disposeBag = DisposeBag()
    
    init(window: UIWindow?) {
        self.window = window
    }
    
    /// 진입 화면을 설정합니다.
    func start() {
        let titleInputVM = TitleInputViewModel(state: .init())
        let titleInputVC = TitleInputViewController(viewModel: titleInputVM)
        navigationController = UINavigationController(rootViewController: titleInputVC)
        navigationController.setNavigationBarHidden(true, animated: false)
        
        titleInputVM.navigation
            .bind(with: self) { owner, path in
                switch path {
                case .pushRecord(let record):
                    owner.pushRecord(titleInputVM, record)
                }
            }
            .disposed(by: disposeBag)
        
        if UserDefaultsService.isTracking {
            let record = UserDefaultsService.record
            titleInputVM.navigation.accept(.pushRecord(record))
        }
        
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
}

// MARK: - Navigation

extension Coordinator {
    
    private func pushRecord(_ titleInputVM: TitleInputViewModel, _ record: Record) {
        let recordVM = RecordViewModel(state: .init(record: .init(value: record)))
        let recordVC = RecordViewController(viewModel: recordVM)
        self.navigationController.pushViewController(recordVC, animated: true)
        
        recordVM.navigation
            .bind(with: self) { owner, path in
                switch path {
                case .pop:
                    owner.navigationController.popViewController(animated: true)
                    
                case .pushEdit(let record):
                    owner.presentEdit(recordVM, record)
                }
            }
            .disposed(by: disposeBag)
    }
    
    private func presentEdit(_ recordVM: RecordViewModel, _ record: Record) {
        let editVM = MomentEditViewModel(
            state: .init(
                record: .init(value: record),
                titleText: .init(value: record.title),
                startDate: .init(value: record.trackingStartDate)
            )
        )
        let editVC = MomentEditViewController(viewModel: editVM)
        editVC.modalPresentationStyle = .overFullScreen
        self.navigationController.present(editVC, animated: true)
        
        editVM.navigation
            .bind(with: self) { owner, path in
                switch path {
                case .presentStartDatePicker(let date):
                    owner.presentDatePickerModal(editVC, editVM, startDate: date)
                    
                case .dismiss(let record):
                    recordVM.delegate.accept(.momentDidEdited(record))
                    editVC.dismiss(animated: true)
                }
            }
            .disposed(by: self.disposeBag)
    }
    
    private func presentDatePickerModal(_ editVC: MomentEditViewController, _ editVM: MomentEditViewModel, startDate: Date) {
        let datePickerVM = DatePickerModalViewModel(state: .init(selectedDate: .init(value: startDate)))
        let datePickerVC = DatePickerModalViewController(viewModel: datePickerVM)
        datePickerVC.sheetPresentationController?.preferredCornerRadius = 20
        datePickerVC.sheetPresentationController?.detents = [.custom(resolver: { _ in 300 })]
        datePickerVC.sheetPresentationController?.prefersGrabberVisible = true
        editVC.present(datePickerVC, animated: true)
        
        datePickerVM.navigation
            .bind(with: self) { owner, path in
                switch path {
                case let .pop(date):
                    editVM.delegate.accept(.startDateDidChanged(date))
                    editVC.dismiss(animated: true)
                }
            }
            .disposed(by: disposeBag)
    }
}
