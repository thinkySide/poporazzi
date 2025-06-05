//
//  ActionButton.swift
//  poporazzi
//
//  Created by 김민준 on 4/19/25.
//

import UIKit
import PinLayout
import FlexLayout

final class ActionButton: CodeBaseUI {
    
    enum Variation {
        case primary
        case secondary
    }
    
    var containerView = UIView()
    
    let tapGesture = UITapGestureRecognizer()
    
    /// 버튼
    let button: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = .setDovemayo(16)
        button.clipsToBounds = true
        return button
    }()
    
    init(title: String, variation: Variation) {
        super.init(frame: .zero)
        setup()
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

extension ActionButton {
    
    enum Action {
        case updateVariation(String, Variation)
        case toggleEnabled(Bool)
    }
    
    func action(_ action: Action) {
        switch action {
        case let .updateVariation(title, variation):
            button.setTitle(title, for: .normal)
            switch variation {
            case .primary:
                button.backgroundColor = .brandPrimary
                button.setTitleColor(.white, for: .normal)
            case .secondary:
                button.backgroundColor = .brandSecondary
                button.setTitleColor(.subLabel, for: .normal)
            }
            
        case let .toggleEnabled(isEnabled):
            UIView.animate(withDuration: 0.2) { [weak self] in
                self?.button.isEnabled = isEnabled
                self?.button.alpha = isEnabled ? 1 : 0.3
            }
        }
    }
}

// MARK: - Layout

extension ActionButton {
    
    func configLayout() {
        containerView.flex.direction(.column).define { flex in
            flex.addItem(button).height(48).cornerRadius(16)
        }
    }
}
