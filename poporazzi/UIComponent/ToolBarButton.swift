//
//  ToolBarButton.swift
//  poporazzi
//
//  Created by 김민준 on 5/4/25.
//

import UIKit
import PinLayout
import FlexLayout

final class ToolBarButton: CodeBaseUI {
    
    var containerView = UIView()
    
    let tapGesture = UITapGestureRecognizer()
    
    var button = UIButton()
    
    init(title: String) {
        super.init(frame: .zero)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.brandPrimary, for: .normal)
        button.titleLabel?.font = .setDovemayo(15)
        setup()
        backgroundColor = .clear
        containerView.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.pin.all(pin.safeArea)
        containerView.flex.layout()
    }
}

// MARK: - Action

extension ToolBarButton {
    
    enum Action {
        case toggleDisabled(Bool)
    }
    
    func action(_ action: Action) {
        switch action {
        case let .toggleDisabled(bool):
            self.alpha = bool ? 0.3 : 1
            self.isUserInteractionEnabled = !bool
        }
    }
}

// MARK: - Layout

extension ToolBarButton {
    
    func configLayout() {
        containerView.flex.define { flex in
            flex.addItem(button).height(24)
        }
    }
}
