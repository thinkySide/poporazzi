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
        case systemIcon(String)
    }
    
    enum ColorType {
        case primary
        case secondary
        
        var background: UIColor {
            switch self {
            case .primary: .brandPrimary
            case .secondary: .brandSecondary
            }
        }
        
        var title: UIColor {
            switch self {
            case .primary: .white
            case .secondary: .subLabel
            }
        }
    }
    
    var containerView = UIView()
    
    private let buttonType: ButtonType
    
    var button = UIButton()
    
    init(buttonType: ButtonType, colorType: ColorType) {
        self.buttonType = buttonType
        super.init(frame: .zero)
        switch buttonType {
        case let .text(title):
            self.button.setTitle(title, for: .normal)
            self.button.setTitleColor(colorType.title, for: .normal)
            self.button.titleLabel?.font = .setDovemayo(15)
        case let .systemIcon(systemName):
            let symbol = UIImage(systemName: systemName)
            self.button.setImage(symbol, for: .normal)
            self.button.tintColor = colorType.title
        }
        self.button.backgroundColor = colorType.background
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

extension NavigationButton {
    
    enum Action {
        
    }
    
    func action(_ action: Action) {
        
    }
}

// MARK: - Layout

extension NavigationButton {
    
    func configLayout() {
        containerView.flex.height(40).define { flex in
            flex.addItem(button).paddingHorizontal(10).height(28).cornerRadius(14)
        }
    }
}
