//
//  ActionButton.swift
//  poporazzi
//
//  Created by 김민준 on 4/4/25.
//

import UIKit
import PinLayout
import FlexLayout

final class ActionButton: CodeBaseUIView {
    
    var containerView = UIView()
    
    /// 버튼
    let button: UIButton = {
        let button = UIButton()
        button.backgroundColor = .brandPrimary
        button.titleLabel?.font = .setPretendard(.bold, 16)
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    init(title: String) {
        super.init(frame: .zero)
        button.setTitle(title, for: .normal)
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.pin.all(pin.safeArea)
        containerView.flex.layout()
    }
}

// MARK: - Action

extension ActionButton {
    
    enum Action {
        case toggleEnabled(Bool)
    }
    
    func action(_ action: Action) {
        switch action {
        case let .toggleEnabled(isEnabled):
            button.isEnabled = isEnabled
            button.alpha = isEnabled ? 1 : 0.3
        }
    }
}

// MARK: - Layout

extension ActionButton {
    
    func configLayout() {
        containerView.flex
            .direction(.column)
            .define { flex in
            flex.addItem(button).height(56)
        }
    }
}
