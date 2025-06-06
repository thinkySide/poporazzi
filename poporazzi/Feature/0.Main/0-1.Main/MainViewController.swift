//
//  MainViewController.swift
//  poporazzi
//
//  Created by 김민준 on 5/23/25.
//

import UIKit
import RxSwift
import RxCocoa

final class MainViewController: UITabBarController {
    
    private let customTabBar = TabBar()
    private let viewModel: MainViewModel
    
    private let viewWillAppear = PublishRelay<Void>()
    private var tabBarBottomConstraint: NSLayoutConstraint!
    private var isTabBarTransitionAnimating = true
    
    private let noTransitionAnimator = NoTransitionAnimator()
    
    let disposeBag = DisposeBag()
    
    init(viewControllers: [UIViewController], selectedTab: Tab, viewModel: MainViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        setViewControllers(viewControllers, animated: false)
        self.selectedIndex = selectedTab.index
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewWillAppear.accept(())
    }
}

// MARK: - 내용입력

extension MainViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isTabBarTransitionAnimating ? nil : noTransitionAnimator
    }
}

// MARK: - Setup

extension MainViewController {
    
    /// TabBar를 세팅합니다.
    private func setupTabBar() {
        self.delegate = self
        tabBar.isHidden = true
        view.addSubview(customTabBar)
        customTabBar.translatesAutoresizingMaskIntoConstraints = false
        tabBarBottomConstraint = customTabBar.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        
        NSLayoutConstraint.activate([
            customTabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customTabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customTabBar.heightAnchor.constraint(equalToConstant: NameSpace.tabBarSize),
            tabBarBottomConstraint
        ])
    }
    
    private func bind() {
        let input = MainViewModel.Input(
            viewWillAppear: viewWillAppear.asSignal(),
            albumListTabTapped: customTabBar.albumListButton.rx.tap.asSignal(),
            recordTabTaaped: customTabBar.recordButton.rx.tap.asSignal(),
            settingsTabTapped: customTabBar.settingsButton.rx.tap.asSignal()
        )
        let output = viewModel.transform(input)
        
        output.selectedTab
            .bind(with: self) { owner, tab in
                owner.isTabBarTransitionAnimating = tab != .record(isTracking: false)
                owner.selectedIndex = tab.index
                owner.customTabBar.action(.updateTab(tab))
            }
            .disposed(by: disposeBag)
        
        output.isTracking
            .bind(with: self) { owner, isTracking in
                owner.customTabBar.action(.updateRecordButton(isTracking: isTracking))
            }
            .disposed(by: disposeBag)
        
        output.toggleTabBar
            .bind(with: self) { owner, bool in
                owner.tabBarBottomConstraint.constant = bool ? 4 : 100
                UIView.animate(withDuration: 0.2) {
                    owner.view.layoutIfNeeded()
                }
            }
            .disposed(by: disposeBag)
        
        output.alertPresented
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, alert in
                owner.showAlert(alert)
            }
            .disposed(by: disposeBag)
    }
}
