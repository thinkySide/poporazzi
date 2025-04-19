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
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        navigationController.setNavigationBarHidden(true, animated: false)
    }
    
    /// RootView 설정 및 시작
    func start() {
        let viewModel = MomentTitleInputViewModel()
        let viewController = MomentTitleInputViewController(coordinator: self, viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: false)
    }
}

// MARK: - Present

extension AppCoordinator {
    
    /// 기록 View Present
    func presentMomentRecortViewController() {
        let viewModel = MomentRecordViewModel()
        let momentRecordVC = MomentRecordViewController(coordinator: self, viewModel: viewModel)
        momentRecordVC.modalPresentationStyle = .fullScreen
        momentRecordVC.modalTransitionStyle = .crossDissolve
        navigationController.present(momentRecordVC, animated: true)
    }
}
