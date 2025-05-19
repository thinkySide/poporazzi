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
    
    enum Variation {
        case title(String)
        case favorite
        case seemore
        case remove
    }
    
    var containerView = UIView()
    
    let tapGesture = UITapGestureRecognizer()
    
    var button = UIButton()
    
    init(_ variation: Variation) {
        super.init(frame: .zero)
        
        switch variation {
        case let .title(text):
            button.setTitle(text, for: .normal)
            button.setTitleColor(.subLabel, for: .normal)
            button.titleLabel?.font = .setDovemayo(16)
            
        case .favorite:
            button.setImage(UIImage(symbol: .likeActive, size: 16, weight: .bold), for: .normal)
            button.tintColor = .subLabel
            
        case .seemore:
            button.setImage(UIImage(symbol: .ellipsis, size: 16, weight: .black), for: .normal)
            button.tintColor = .subLabel
            
        case .remove:
            button.setImage(UIImage(symbol: .remove, size: 16, weight: .bold), for: .normal)
            button.tintColor = .subLabel
        }
        
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
            UIView.animate(withDuration: 0.2) { [weak self] in
                self?.alpha = bool ? 0.4 : 1
                self?.isUserInteractionEnabled = !bool
            }
        }
    }
}

// MARK: - Layout

extension ToolBarButton {
    
    func configLayout() {
        containerView.flex.define { flex in
            flex.addItem(button)
                .paddingHorizontal(16)
                .backgroundColor(.brandSecondary)
                .cornerRadius(19)
                .height(38)
        }
    }
}
