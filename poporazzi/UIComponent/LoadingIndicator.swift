//
//  LoadingIndicator.swift
//  poporazzi
//
//  Created by 김민준 on 5/5/25.
//

import UIKit
import PinLayout
import FlexLayout

final class LoadingIndicator: CodeBaseUI {
    
    var containerView = UIView()
    
    private let indicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        return indicator
    }()
    
    init() {
        super.init(frame: .zero)
        setup()
        backgroundColor = .black.withAlphaComponent(0.3)
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

extension LoadingIndicator {
    
    enum Action {
        case start
        case stop
    }
    
    func action(_ action: Action) {
        switch action {
        case .start: indicator.startAnimating()
        case .stop: indicator.stopAnimating()
        }
    }
}

// MARK: - Layout

extension LoadingIndicator {
    
    func configLayout() {
        containerView.flex.define { flex in
            flex.addItem(indicator).position(.absolute).alignSelf(.center).top(50%)
        }
    }
}
