//
//  TabViewController.swift
//  poporazzi
//
//  Created by 김민준 on 5/23/25.
//

import UIKit
import RxSwift
import RxCocoa
import PinLayout
import FlexLayout

final class TabViewController: UITabBarController {
    
    private let containerView = UIView()
    private let customTabBar = TabBar()
    
    let disposeBag = DisposeBag()
    
    init(viewControllers: [UIViewController]) {
        super.init(nibName: nil, bundle: nil)
        setViewControllers(viewControllers, animated: false)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
        setupEvent()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        containerView.pin.all()
        containerView.flex.layout()
    }
}

// MARK: - Setup

extension TabViewController {
    
    /// TabBar를 세팅합니다.
    private func setupTabBar() {
        tabBar.isHidden = true
        view.addSubview(containerView)
        
        containerView.flex.direction(.column).define { flex in
            flex.addItem().grow(1)
            flex.addItem(customTabBar).paddingBottom(24)
        }
    }
    
    /// 이벤트를 설정합니다.
    private func setupEvent() {
        customTabBar.albumListButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.selectedIndex = 0
            }
            .disposed(by: disposeBag)
        
        customTabBar.recordButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.selectedIndex = 1
            }
            .disposed(by: disposeBag)
        
        customTabBar.settingsButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.selectedIndex = 2
            }
            .disposed(by: disposeBag)
    }
}
