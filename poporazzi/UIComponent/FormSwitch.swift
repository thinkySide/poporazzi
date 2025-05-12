//
//  FormSwitch.swift
//  poporazzi
//
//  Created by 김민준 on 5/12/25.
//

import UIKit
import PinLayout
import FlexLayout

final class FormSwitch: CodeBaseUI {
    
    var containerView = UIView()
    
    private let formLabel = UILabel("", size: 16, color: .mainLabel)
    
    let controlSwitch: UISwitch = {
        let control = UISwitch()
        control.onTintColor = .brandPrimary
        return control
    }()
    
    init(title: String) {
        super.init(frame: .zero)
        formLabel.text = title
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

// MARK: - Layout

extension FormSwitch {
    
    func configLayout() {
        containerView.flex.direction(.row).define { flex in
            flex.addItem(formLabel)
            flex.addItem().grow(1)
            flex.addItem(controlSwitch)
        }
    }
}
