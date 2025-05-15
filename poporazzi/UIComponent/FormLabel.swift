//
//  FormLabel.swift
//  poporazzi
//
//  Created by 김민준 on 4/17/25.
//

import UIKit
import PinLayout
import FlexLayout

final class FormLabel: CodeBaseUI {
    
    var containerView = UIView()
    
    /// 앨범 제목 라벨
    private let mainLabel = UILabel(size: 16, color: .subLabel)
    
    private let subLabel = UILabel(size: 16, color: .subLabel)
    
    init(title: String, subtitle: String = "") {
        super.init(frame: .zero)
        mainLabel.text = title
        self.subLabel.text = subtitle
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

extension FormLabel {
    
    enum Action {
        case updateSubLabel(text: String, color: UIColor)
    }
    
    func action(_ action: Action) {
        switch action {
        case let .updateSubLabel(text, color):
            subLabel.text = text
            subLabel.textColor = color
            subLabel.flex.markDirty()
            setNeedsLayout()
        }
    }
}

// MARK: - Layout

extension FormLabel {
    
    func configLayout() {
        containerView.flex.direction(.row).justifyContent(.spaceBetween).define { flex in
            flex.addItem(mainLabel)
            flex.addItem(subLabel)
        }
    }
}
