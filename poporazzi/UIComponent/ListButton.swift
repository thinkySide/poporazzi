//
//  ListButton.swift
//  poporazzi
//
//  Created by 김민준 on 6/1/25.
//

import UIKit
import PinLayout
import FlexLayout

final class ListButton: CodeBaseUI {
    
    var containerView = UIView()
    
    let tapGesture = UITapGestureRecognizer()
    
    private let titleLabel = UILabel(size: 18, color: .mainLabel)
    
    private let chevronRight = UIImageView(
        symbol: .right,
        size: 13,
        weight: .semibold,
        tintColor: .subLabel
    )
    
    init(title: String) {
        super.init(frame: .zero)
        titleLabel.text = title
        setup()
        addGestureRecognizer(tapGesture)
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

extension ListButton {
    
    enum Action {
        
    }
    
    func action(_ action: Action) {
        
    }
}

// MARK: - Layout

extension ListButton {
    
    func configLayout() {
        containerView.flex.direction(.row).height(40).justifyContent(.spaceBetween).define { flex in
            flex.addItem(titleLabel).grow(1)
            flex.addItem(chevronRight)
        }
    }
}
