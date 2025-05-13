//
//  FormCheckBox.swift
//  poporazzi
//
//  Created by 김민준 on 5/13/25.
//

import UIKit
import PinLayout
import FlexLayout

final class FormCheckBox: CodeBaseUI {
    
    enum Variation {
        case selected
        case deselected
        
        var backgroundColor: UIColor {
            switch self {
            case .selected: .brandPrimary
            case .deselected: .brandSecondary
            }
        }
    }
    
    var containerView = UIView()
    
    let title = UILabel(size: 18, color: .mainLabel)
    
    let button: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(symbol: .checkBox, size: 24, weight: .black), for: .normal)
        button.backgroundColor = .white
        return button
    }()
    
    init(_ title: String, variation: Variation) {
        super.init(frame: .zero)
        self.title.text = title
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

extension FormCheckBox {
    
    enum Action {
        case updateVariation(Variation)
    }
    
    func action(_ action: Action) {
        switch action {
        case let .updateVariation(variation):
            UIView.animate(withDuration: 0.2) { [weak self] in
                self?.button.layer.opacity = variation == .selected ? 1 : 0.2
            }
        }
    }
}

// MARK: - Layout

extension FormCheckBox {
    
    func configLayout() {
        containerView.flex.direction(.row).define { flex in
            flex.addItem(title)
            flex.addItem().grow(1)
            flex.addItem(button).size(.init(width: 40, height: 40))
        }
    }
}
