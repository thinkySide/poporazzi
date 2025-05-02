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
    
    init(window: UIWindow?) {
        self.window = window
    }
    
    /// 진입 화면을 설정합니다.
    func start() {
        DIContainer.shared.injectDependencies()
        let titleInputVM = TitleInputViewModel(output: .init())
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
            .disposed(by: titleInputVC.disposeBag)
        
        if UserDefaultsService.isTracking {
            let record = UserDefaultsService.record
            titleInputVM.navigation.accept(.pushRecord(record))
        }
        
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
}

// MARK: - Navigation Path

extension Coordinator {
    
    /// 기록 화면으로 Push 합니다.
    private func pushRecord(_ titleInputVM: TitleInputViewModel, _ record: Record) {
        let recordVM = RecordViewModel(output: .init(record: .init(value: record)))
        let recordVC = RecordViewController(viewModel: recordVM)
        self.navigationController.pushViewController(recordVC, animated: true)
        
        recordVM.navigation
            .bind(with: self) { owner, path in
                switch path {
                case .pop:
                    owner.navigationController.popViewController(animated: true)
                    
                case let .pushEdit(record):
                    owner.presentEdit(recordVM, record)
                }
            }
            .disposed(by: recordVC.disposeBag)
    }
}

// MARK: - Sheet

extension Coordinator {
    
    /// 기록 수정 화면을 Present 합니다.
    private func presentEdit(_ recordVM: RecordViewModel, _ record: Record) {
        let editVM = MomentEditViewModel(
            output: .init(
                record: .init(value: record),
                titleText: .init(value: record.title),
                startDate: .init(value: record.trackingStartDate)
            )
        )
        let editVC = MomentEditViewController(viewModel: editVM)
        editVC.modalPresentationStyle = .overFullScreen
        self.navigationController.present(editVC, animated: true)
        
        editVM.navigation
            .bind(with: self) { [weak editVC] owner, path in
                switch path {
                case .presentStartDatePicker(let date):
                    owner.presentDatePickerModal(editVC, editVM, startDate: date)
                    
                case .dismiss(let record):
                    recordVM.delegate.accept(.momentDidEdited(record))
                    editVC?.dismiss(animated: true)
                }
            }
            .disposed(by: editVC.disposeBag)
    }
    
    /// 날짜 선택 모달을 Present합니다.
    private func presentDatePickerModal(_ editVC: MomentEditViewController?, _ editVM: MomentEditViewModel, startDate: Date) {
        let datePickerVM = DatePickerModalViewModel(output: .init(selectedDate: .init(value: startDate)))
        let datePickerVC = DatePickerModalViewController(viewModel: datePickerVM)
        datePickerVC.sheetPresentationController?.preferredCornerRadius = 20
        datePickerVC.sheetPresentationController?.detents = [.custom(resolver: { _ in 300 })]
        datePickerVC.sheetPresentationController?.prefersGrabberVisible = true
        editVC?.present(datePickerVC, animated: true)
        
        datePickerVM.navigation
            .bind(with: self) { owner, path in
                switch path {
                case let .pop(date):
                    editVM.delegate.accept(.startDateDidChanged(date))
                    editVC?.dismiss(animated: true)
                }
            }
            .disposed(by: datePickerVC.disposeBag)
    }
}
