//
//  TabViewController.swift
//  poporazzi
//
//  Created by 김민준 on 5/23/25.
//

import UIKit
import RxSwift
import RxCocoa

final class TabViewController: UITabBarController {
    
    private let customTabBar = TabBar()
    
    let currentTab: BehaviorRelay<Tab>
    let isTracking: BehaviorRelay<Bool>
    
    let disposeBag = DisposeBag()
    
    init(viewControllers: [UIViewController], currentTab: Tab, isTracking: Bool) {
        self.currentTab = .init(value: currentTab)
        self.isTracking = .init(value: isTracking)
        super.init(nibName: nil, bundle: nil)
        setViewControllers(viewControllers, animated: false)
        self.selectedIndex = currentTab.index
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
        setupEvent()
    }
}

// MARK: - Setup

extension TabViewController {
    
    /// TabBar를 세팅합니다.
    private func setupTabBar() {
        tabBar.isHidden = true
        view.addSubview(customTabBar)
        customTabBar.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            customTabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customTabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customTabBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 4),
            customTabBar.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
    
    /// 이벤트를 설정합니다.
    private func setupEvent() {
        currentTab
            .bind(with: self) { owner, tab in
                owner.selectedIndex = tab.index
                let isTracking = owner.isTracking.value
                owner.customTabBar.action(.updateTab(tab, isTracking: isTracking))
                HapticManager.impact(style: .soft)
            }
            .disposed(by: disposeBag)
        
        isTracking
            .bind(with: self) { owner, isTracking in
                owner.customTabBar.action(.updateRecordButton(isTracking: isTracking))
            }
            .disposed(by: disposeBag)
        
        customTabBar.albumListButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.currentTab.accept(.albumList)
            }
            .disposed(by: disposeBag)
        
        customTabBar.recordButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.currentTab.accept(.record(isTracking: false))
            }
            .disposed(by: disposeBag)
        
        customTabBar.settingsButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.currentTab.accept(.settings)
            }
            .disposed(by: disposeBag)
    }
}
