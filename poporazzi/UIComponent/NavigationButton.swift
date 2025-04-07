//
//  NavigationButton.swift
//  poporazzi
//
//  Created by 김민준 on 4/7/25.
//

import UIKit
import PinLayout
import FlexLayout

final class NavigationButton: CodeBaseUIView {
    
    /// 버튼 타입
    enum ButtonType {
        case text(String)
        case systemIcon(String)
    }
    
    var containerView = UIView()
    
    private let buttonType: ButtonType
    
    var button = UIButton()
    
    init(buttonType: ButtonType) {
        self.buttonType = buttonType
        super.init(frame: .zero)
        switch buttonType {
        case let .text(title):
            self.button.setTitle(title, for: .normal)
            self.button.setTitleColor(.brandPrimary, for: .normal)
            self.button.titleLabel?.font = .setPretendard(.semiBold, 15)
        case let .systemIcon(systemName):
            self.button.setImage(UIImage(systemName: systemName), for: .normal)
        }
        setup()
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
            flex.addItem(button)
        }
    }
}

