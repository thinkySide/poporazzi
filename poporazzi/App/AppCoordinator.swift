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
    
    /// 공유 상태
    private var sharedState = SharedState()
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        navigationController.setNavigationBarHidden(true, animated: false)
    }
    
    /// RootView 설정 및 시작
    func start() {
        let viewModel = MomentTitleInputViewModel(sharedState: sharedState)
        let viewController = MomentTitleInputViewController(coordinator: self, viewModel: viewModel)
        push(viewController)
    }
}

// MARK: - Helper

extension AppCoordinator {
    
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
    func presentMomentRecord() {
        let viewModel = MomentRecordViewModel(sharedState: sharedState)
        let momentRecordVC = MomentRecordViewController(coordinator: self, viewModel: viewModel)
        momentRecordVC.modalPresentationStyle = .fullScreen
        momentRecordVC.modalTransitionStyle = .crossDissolve
        present(momentRecordVC)
    }
    
    /// 기록 수정 화면을 출력합니다.
    func presentMomentEdit() {
        let viewModel = MomentEditViewModel()
        let momentEditVC = MomentEditViewController(coordinator: self, viewModel: viewModel)
        momentEditVC.modalPresentationStyle = .overFullScreen
        present(momentEditVC)
    }
    
    /// 날짜 선택 모달을 출력합니다.
    func presentDatePickerModal() {
        let viewModel = DatePickerModalViewModel()
        let datePickerVC = DatePickerModalViewController(coordinator: self, viewModel: viewModel)
        datePickerVC.sheetPresentationController?.preferredCornerRadius = 20
        datePickerVC.sheetPresentationController?.detents = [.custom(resolver: { _ in 300 })]
        datePickerVC.sheetPresentationController?.prefersGrabberVisible = true
        present(datePickerVC)
    }
}
