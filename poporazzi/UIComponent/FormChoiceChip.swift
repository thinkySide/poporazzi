//
//  ChoiceChip.swift
//  poporazzi
//
//  Created by 김민준 on 5/13/25.
//

import UIKit
import PinLayout
import FlexLayout

final class FormChoiceChip: CodeBaseUI {
    
    enum Variation {
        case selected
        case deselected
        
        var backgroundColor: UIColor {
            switch self {
            case .selected: .brandPrimary
            case .deselected: .brandSecondary
            }
        }
        
        var textColor: UIColor {
            switch self {
            case .selected: .white
            case .deselected: .subLabel
            }
        }
    }
    
    var containerView = UIView()
    
    /// 버튼
    let button: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = .setDovemayo(16)
        button.backgroundColor = .white
        button.setTitleColor(.mainLabel, for: .normal)
        return button
    }()
    
    init(_ title: String, variation: Variation) {
        super.init(frame: .zero)
        self.button.setTitle(title, for: .normal)
        self.action(.updateVariation(variation))
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

extension FormChoiceChip {
    
    enum Action {
        case updateVariation(Variation)
    }
    
    func action(_ action: Action) {
        switch action {
        case let .updateVariation(variation):
            UIView.animate(withDuration: 0.2) { [weak self] in
                self?.button.backgroundColor = variation.backgroundColor
                self?.button.setTitleColor(variation.textColor, for: .normal)
            }
        }
    }
}

// MARK: - Layout

extension FormChoiceChip {
    
    func configLayout() {
        containerView.flex.define { flex in
            flex.addItem(button).height(38).paddingHorizontal(16).cornerRadius(19)
        }
    }
}
