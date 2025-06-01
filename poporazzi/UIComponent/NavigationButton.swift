//
//  NavigationButton.swift
//  poporazzi
//
//  Created by 김민준 on 4/7/25.
//

import UIKit
import PinLayout
import FlexLayout

final class NavigationButton: CodeBaseUI {
    
    /// 버튼 타입
    enum ButtonType {
        case text(String)
        case back
        case xmark
        case seemore
    }
    
    enum Variation {
        case primary
        case secondary
        case tertiary
        
        var backgroundColor: UIColor {
            switch self {
            case .primary: .brandPrimary
            case .secondary: .brandSecondary
            case .tertiary: .subButton
            }
        }
        
        var titleColor: UIColor {
            switch self {
            case .primary: .white
            case .secondary: .subIcon
            case .tertiary: .subIcon
            }
        }
    }
    
    var containerView = UIView()
    
    private let buttonType: ButtonType
    
    var button = UIButton()
    
    init(buttonType: ButtonType, variation: Variation = .secondary) {
        self.buttonType = buttonType
        super.init(frame: .zero)
        
        switch buttonType {
        case let .text(title):
            self.button.setTitle(title, for: .normal)
            self.button.setTitleColor(variation.titleColor, for: .normal)
            self.button.titleLabel?.font = .setDovemayo(15)
            
        case .back:
            let symbol = UIImage(symbol: .left, size: 12, weight: .bold)
            self.button.setImage(symbol, for: .normal)
            self.button.tintColor = variation.titleColor
            
        case .xmark:
            let symbol = UIImage(symbol: .dismiss, size: 12, weight: .bold)
            self.button.setImage(symbol, for: .normal)
            self.button.tintColor = variation.titleColor
            
        case .seemore:
            let symbol = UIImage(symbol: .ellipsis, size: 14, weight: .black)
            self.button.setImage(symbol, for: .normal)
            self.button.tintColor = variation.titleColor
        }
        
        self.button.backgroundColor = variation.backgroundColor
        setup(color: .clear)
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

extension NavigationButton {
    
    enum Action {
        case toggleDisabled(Bool)
    }
    
    func action(_ action: Action) {
        switch action {
        case let .toggleDisabled(bool):
            self.alpha = bool ? 0.4 : 1
            self.isUserInteractionEnabled = !bool
        }
    }
}

// MARK: - Layout

extension NavigationButton {
    
    func configLayout() {
        containerView.flex.define { flex in
            switch buttonType {
            case .text, .seemore:
                flex.addItem(button).paddingHorizontal(12).height(32).cornerRadius(16)
                
            case .back, .xmark:
                flex.addItem(button).width(32).height(32).cornerRadius(16)
            }
        }
    }
}
