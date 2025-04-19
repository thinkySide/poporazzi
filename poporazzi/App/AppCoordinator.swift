//
//  AppCoordinator.swift
//  poporazzi
//
//  Created by 김민준 on 4/19/25.
//

import UIKit
import RxSwift

final class AppCoordinator {
    
    /// 기본 네비게이션
    private let navigationController: UINavigationController
    
    /// 화면 스택
    private var viewStack: [UIViewController] = []
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        navigationController.setNavigationBarHidden(true, animated: false)
    }
    
    let momentTitleInputViewModel = MomentTitleInputViewModel()
    let momentRecordViewModel = MomentRecordViewModel()
    let momentEditViewModel = MomentEditViewModel()
    let datePickerModalViewModel = DatePickerModalViewModel()
}

// MARK: - Helper

extension AppCoordinator {
    
    /// RootView 설정 및 시작
    func start() {
        let viewController = MomentTitleInputViewController(coordinator: self, viewModel: momentTitleInputViewModel)
        navigationController.pushViewController(viewController, animated: false)
        viewStack.append(viewController)
        
        //        if sharedState.isTracking.value {
        //            pushMomentRecord()
        //        }
    }
    
    private func push(_ viewController: UIViewController) {
        navigationController.pushViewController(viewController, animated: true)
        viewStack.append(viewController)
    }
    
    private func present(_ viewController: UIViewController) {
        viewStack.last?.present(viewController, animated: true)
        viewStack.append(viewController)
    }
    
    func pop() {
        navigationController.popViewController(animated: true)
        viewStack.removeLast()
    }
    
    func dismiss() {
        viewStack.last?.dismiss(animated: true)
        viewStack.removeLast()
    }
}

// MARK: - Present

extension AppCoordinator {
    
    /// 기록 트래킹 화면을 출력합니다.
    func pushMomentRecord(record: Record) {
        let viewController = MomentRecordViewController(coordinator: self, viewModel: momentRecordViewModel)
        momentRecordViewModel.record.accept(record)
        viewController.modalPresentationStyle = .fullScreen
        viewController.modalTransitionStyle = .crossDissolve
        push(viewController)
    }
    
    /// 기록 수정 화면을 출력합니다.
    func presentMomentEdit(record: Record) {
        let momentEditVC = MomentEditViewController(coordinator: self, viewModel: momentEditViewModel)
        momentEditViewModel.record.accept(record)
        momentEditVC.modalPresentationStyle = .overFullScreen
        present(momentEditVC)
    }
    
    /// 날짜 선택 모달을 출력합니다.
    func presentDatePickerModal(selectedDate: Date) {
        let datePickerVC = DatePickerModalViewController(coordinator: self, viewModel: datePickerModalViewModel)
        datePickerModalViewModel.selectedDate.accept(selectedDate)
        datePickerVC.sheetPresentationController?.preferredCornerRadius = 20
        datePickerVC.sheetPresentationController?.detents = [.custom(resolver: { _ in 300 })]
        datePickerVC.sheetPresentationController?.prefersGrabberVisible = true
        present(datePickerVC)
    }
}
