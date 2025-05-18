//
//  SymbolLabel.swift
//  poporazzi
//
//  Created by 김민준 on 5/5/25.
//

import UIKit
import PinLayout
import FlexLayout

final class SymbolLabel: CodeBaseUI {
    
    var containerView = UIView()
    
    /// 아이콘
    private let symbolView = UIImageView(symbol: .check, size: 12, weight: .black, tintColor: .brandPrimary)
    
    /// 정보 라벨
    let label: UILabel = {
        let label = UILabel()
        label.font = .setDovemayo(14)
        label.textColor = .subLabel
        return label
    }()
    
    init(title: String = "", symbol: SFSymbol, tintColor: UIColor) {
        super.init(frame: .zero)
        label.text = title
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

extension SymbolLabel {
    
    enum Action {
        case updateLabel(String)
        case toggleSymbol(Bool)
    }
    
    func action(_ action: Action) {
        switch action {
        case let .updateLabel(text):
            label.text = text
            label.flex.markDirty()
            
        case let .toggleSymbol(bool):
            symbolView.isHidden = !bool
        }
    }
}

// MARK: - Layout

extension SymbolLabel {
    
    func configLayout() {
        containerView.flex.direction(.row).define { flex in
            flex.addItem(symbolView)
            flex.addItem(label).marginLeft(4)
        }
    }
}
