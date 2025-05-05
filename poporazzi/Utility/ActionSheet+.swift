//
//  ActionSheet+.swift
//  poporazzi
//
//  Created by 김민준 on 5/5/25.
//

import UIKit

/// Action Sheet 타입
struct ActionSheetModel {
    let title: String?
    let message: String?
    let buttons: [ActionSheetButton]
    
    init(
        title: String? = nil,
        message: String? = nil,
        buttons: [ActionSheetButton]
    ) {
        self.title = title
        self.message = message
        self.buttons = buttons
    }
}

/// Action Sheet 버튼
struct ActionSheetButton {
    let title: String
    let style: UIAlertAction.Style
    let action: (() -> Void)?
    
    init(
        title: String,
        style: UIAlertAction.Style,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.style = style
        self.action = action
    }
}

// MARK: - Action Sheet Helper

extension UIViewController {
    
    /// Action Sheet를 출력합니다.
    func showActionSheet(_ model: ActionSheetModel) {
        let actionSheet = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .actionSheet
        )
        
        for button in model.buttons {
            let actionButton = UIAlertAction(
                title: button.title,
                style: button.style,
                handler: { _ in
                    button.action?()
                }
            )
            actionSheet.addAction(actionButton)
        }
        
        self.present(actionSheet, animated: true)
    }
}
