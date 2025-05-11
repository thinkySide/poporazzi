//
//  CancelButton.swift
//  poporazzi
//
//  Created by 김민준 on 5/11/25.
//

import UIKit
import PinLayout
import FlexLayout

final class CancelButton: CodeBaseUI {
    
    var containerView = UIView()
    
    /// 버튼
    let button: UIButton = {
        let button = UIButton()
        button.setTitle("취소", for: .normal)
        button.titleLabel?.font = .setDovemayo(16)
        button.backgroundColor = .white
        button.setTitleColor(.mainLabel, for: .normal)
        return button
    }()
    
    init() {
        super.init(frame: .zero)
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

extension CancelButton {
    
    func configLayout() {
        containerView.flex.define { flex in
            flex.addItem(button).paddingVertical(4).width(64)
        }
    }
}
