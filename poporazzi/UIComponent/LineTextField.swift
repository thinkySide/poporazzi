//
//  LineTextField.swift
//  poporazzi
//
//  Created by 김민준 on 4/4/25.
//

import UIKit
import PinLayout
import FlexLayout

final class LineTextField: CodeBaseUI {
    
    var containerView = UIView()
    
    let tapGesture = UITapGestureRecognizer()
    
    /// 텍스트필드
    let textField: UITextField = {
        let textField = UITextField()
        textField.textColor = .mainLabel
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        return textField
    }()
    
    /// 하단 라인
    private let bottomLine: UIView = {
        let line = UIView()
        line.backgroundColor = .line
        return line
    }()
    
    init(size: CGFloat, placeholder: String) {
        super.init(frame: .zero)
        textField.font = .setDovemayo(size)
        textField.placeholder = placeholder
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

extension LineTextField {
    
    enum Action {
        case setupInputAccessoryView(UIView)
        case presentKeyboard
        case dismissKeyboard
        case toggleLine
        case updateText(String)
        case updatePlaceholder(String)
    }
    
    func action(_ action: Action) {
        switch action {
        case let .setupInputAccessoryView(view):
            textField.inputAccessoryView = view
            
        case .presentKeyboard:
            textField.becomeFirstResponder()
            
        case .dismissKeyboard:
            textField.resignFirstResponder()
            
        case .toggleLine:
            if !textField.isFirstResponder {
                bottomLine.backgroundColor = .line
            } else {
                bottomLine.backgroundColor = .brandPrimary
            }
            
        case let .updateText(text):
            textField.text = text
            
        case let .updatePlaceholder(text):
            textField.placeholder = text
        }
    }
}

// MARK: - Layout

extension LineTextField {
    
    func configLayout() {
        containerView.flex.direction(.column).define { flex in
            flex.addItem(textField)
            flex.addItem(bottomLine).marginTop(10).height(2)
        }
    }
}
