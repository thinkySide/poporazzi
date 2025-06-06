//
//  AlertModel+.swift
//  poporazzi
//
//  Created by 김민준 on 4/9/25.
//

import UIKit

/// Alert 타입
struct AlertModel {
    let title: String
    let message: String?
    let eventButton: AlertButton
    let cancelButton: AlertButton?
    
    init(
        title: String,
        message: String? = nil,
        eventButton: AlertButton,
        cancelButton: AlertButton? = nil
    ) {
        self.title = title
        self.message = message
        self.eventButton = eventButton
        self.cancelButton = cancelButton
    }
}

/// Alert 버튼
struct AlertButton {
    let title: String
    let isDestructive: Bool
    let action: (() -> Void)?
    
    init(
        title: String,
        isDestructive: Bool = false,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.isDestructive = isDestructive
        self.action = action
    }
}

// MARK: - Alert Helper

extension UIViewController {
    
    /// Alert를 출력합니다.
    func showAlert(_ alert: AlertModel) {
        let alertController = UIAlertController(
            title: alert.title,
            message: alert.message,
            preferredStyle: .alert
        )
        
        let action = UIAlertAction(
            title: alert.eventButton.title,
            style: alert.eventButton.isDestructive ? .destructive : .default
        ) { _ in
            alert.eventButton.action?()
        }
        alertController.addAction(action)
        
        if let cancelButton = alert.cancelButton {
            let cancelAction = UIAlertAction(title: cancelButton.title, style: .cancel) { _ in
                alert.cancelButton?.action?()
            }
            alertController.addAction(cancelAction)
        }
        
        self.present(alertController, animated: true)
    }
}
