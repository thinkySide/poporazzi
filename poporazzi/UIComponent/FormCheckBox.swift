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
    
    let tapGesture = UITapGestureRecognizer()
    
    let checkBoxIcon = UIImageView(
        symbol: .checkBox,
        size: 24,
        weight: .black,
        tintColor: .brandSecondary
    )
    
    let title = UILabel(size: 16, color: .mainLabel)
    
    init(_ title: String, variation: Variation) {
        super.init(frame: .zero)
        self.title.text = title
        self.action(.updateVariation(variation))
        addGestureRecognizer(tapGesture)
        setup(color: .white)
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
                self?.checkBoxIcon.tintColor = variation.backgroundColor
            }
        }
    }
}

// MARK: - Layout

extension FormCheckBox {
    
    func configLayout() {
        containerView.flex.direction(.row).height(40).define { flex in
            flex.addItem(checkBoxIcon)
            flex.addItem(title).marginLeft(12)
            flex.addItem().grow(1)
        }
    }
}
