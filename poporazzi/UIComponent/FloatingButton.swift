//
//  FloatingButton.swift
//  poporazzi
//
//  Created by 김민준 on 4/17/25.
//

import UIKit
import PinLayout
import FlexLayout

final class FloatingButton: CodeBaseUI {
    
    var containerView = UIView()
    
    let tapGesture = UITapGestureRecognizer()
    
    /// 버튼
    let button: UIButton = {
        let button = UIButton()
        button.backgroundColor = .brandPrimary
        button.setTitleColor(.white, for: .normal)
        button.clipsToBounds = true
        button.layer.cornerRadius = 28
        button.layer.borderWidth = 3
        button.layer.borderColor = UIColor.brandPrimary.withAlphaComponent(0.1).cgColor
        return button
    }()
    
    init(symbol: SFSymbol) {
        super.init(frame: .zero)
        
        defer {
            self.backgroundColor = .clear
            self.containerView.backgroundColor = .clear
        }
        
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .bold)
        let symbol = UIImage(systemName: symbol.rawValue, withConfiguration: config)
        self.button.setImage(symbol, for: .normal)
        self.button.backgroundColor = .brandSecondary
        self.button.tintColor = .brandPrimary.withAlphaComponent(0.5)
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

// MARK: - Layout

extension FloatingButton {
    
    func configLayout() {
        containerView.flex.direction(.column).define { flex in
            flex.addItem(button).size(.init(width: 56, height: 56)).cornerRadius(28)
        }
    }
}
