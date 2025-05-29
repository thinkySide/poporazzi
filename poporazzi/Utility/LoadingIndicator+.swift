//
//  LoadingIndicator+.swift
//  poporazzi
//
//  Created by 김민준 on 5/29/25.
//

import UIKit
import ObjectiveC

extension UIViewController {
    
    // Associated Object를 위한 고유한 키 (static let)
    private struct AssociatedKeys {
        static var loadingIndicator: UInt8 = 0
    }
    
    // UIViewController에서 접근할 로딩 인디케이터
    private var loadingIndicator: LoadingIndicator {
        if let indicator = objc_getAssociatedObject(self, &AssociatedKeys.loadingIndicator) as? LoadingIndicator {
            return indicator
        } else {
            let newIndicator = LoadingIndicator()
            objc_setAssociatedObject(self, &AssociatedKeys.loadingIndicator, newIndicator, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return newIndicator
        }
    }
    
    /// 로딩 인디케이터를 설정합니다.
    func setupLoadingIndicator() {
        if loadingIndicator.superview == nil {
            view.addSubview(loadingIndicator)
            loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                loadingIndicator.topAnchor.constraint(equalTo: view.topAnchor),
                loadingIndicator.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                loadingIndicator.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                loadingIndicator.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
        }
    }
    
    /// 로딩 인디케이터를 토글합니다.
    func toggleLoadingIndicator(_ isActive: Bool) {
        if isActive {
            loadingIndicator.action(.start)
        } else {
            loadingIndicator.action(.stop)
        }
    }
}
