//
//  RadioButton.swift
//  poporazzi
//
//  Created by 김민준 on 5/11/25.
//

import UIKit
import PinLayout
import FlexLayout

final class RadioButton: CodeBaseUI {
    
    enum Variation {
        case selected
        case deselected
        
        var icon: UIImage {
            switch self {
            case .selected: .radioSelect
            case .deselected: .radioDeselect
            }
        }
        
        var backgroundColor: UIColor {
            switch self {
            case .selected: .brandSecondary
            case .deselected: .brandTertiary
            }
        }
        
        var strokeColor: UIColor {
            switch self {
            case .selected: .brandPrimary
            case .deselected: .white
            }
        }
    }
    
    var containerView = UIView()
    
    let tapGesture = UITapGestureRecognizer()
    
    let radioIcon: UIImageView = {
        let icon = UIImageView()
        icon.contentMode = .scaleAspectFill
        return icon
    }()
    
    private let textContainerView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.borderWidth = 2
        return view
    }()
    
    private let titleLabel = UILabel(size: 16, color: .mainLabel)
    
    private let subLabel = UILabel(size: 13, color: .subLabel)
    
    init(title: String, sub: String, variation: Variation) {
        super.init(frame: .zero)
        titleLabel.text = title
        subLabel.text = sub
        action(.updateState(variation))
        addGestureRecognizer(tapGesture)
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

extension RadioButton {
    
    enum Action {
        case updateState(Variation)
    }
    
    func action(_ action: Action) {
        switch action {
        case .updateState(let variation):
            UIView.animate(withDuration: 0.2, delay: 0, options: .allowUserInteraction) { [weak self] in
                self?.textContainerView.backgroundColor = variation.backgroundColor
                self?.textContainerView.layer.borderColor = variation.strokeColor.cgColor
                self?.radioIcon.image = variation.icon
            }
        }
    }
}

// MARK: - Layout

extension RadioButton {
    
    func configLayout() {
        containerView.flex.direction(.row).alignItems(.center).height(68).define { flex in
            flex.addItem(radioIcon).size(.init(width: 28, height: 28))
            flex.addItem(textContainerView).marginLeft(8).grow(1)
        }
        
        textContainerView.flex.direction(.column)
            .paddingHorizontal(16)
            .paddingVertical(12)
            .cornerRadius(12)
            .define { flex in
                flex.addItem(titleLabel)
                flex.addItem(subLabel).marginTop(6)
            }
    }
}
