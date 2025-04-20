//
//  ViewController+.swift
//  poporazzi
//
//  Created by 김민준 on 4/5/25.
//

import UIKit
import RxSwift

/// ViewController 프로토콜을 편리하게 사용하기 위한 별칭
typealias ViewController = UIViewController & ViewControllerProtocol

/// ViewController 구현 시 필요한 필수 구현 프로토콜
protocol ViewControllerProtocol: UIViewController {
    
    /// Input과 Ounput을 Binding합니다.
    func bind()
}

class BaseViewController: UIViewController {
    
    weak var coordinator: AppCoordinator?
    
    init(coordinator: AppCoordinator?) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
}

// MARK: - UIViewController 기본 구현

extension UIViewController {
    
    /// 생성자 직접 구현 시 필수 구현 생성자
    convenience init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
