//
//  MessageBox.swift
//  poporazzi
//
//  Created by 김민준 on 5/31/25.
//

import UIKit
import PinLayout
import FlexLayout

final class MessageBox: CodeBaseUI {
    
    var containerView = UIView()
    
    let icon: UIImageView = {
        let icon = UIImageView()
        icon.image = UIImage(resource: .appIcon)
        icon.clipsToBounds = true
        return icon
    }()
    
    let messageLabel: UILabel = {
        let label = UILabel()
        label.font = .setDovemayo(16)
        label.textColor = .mainLabel
        label.numberOfLines = 2
        label.text = """
        포포라치가 벌써 3일째
        당신의 하루를 기록 중이에요 📸
        """
        label.setLine(alignment: .left, spacing: 4)
        return label
    }()
    
    init() {
        super.init(frame: .zero)
        setup(color: .brandSecondary)
        self.clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.pin.all(pin.safeArea)
        containerView.flex.layout()
        self.layer.cornerRadius = 12
    }
}

// MARK: - Action

extension MessageBox {
    
    enum Action {
        
    }
    
    func action(_ action: Action) {
        switch action {
            
        }
    }
}

// MARK: - Layout

extension MessageBox {
    
    func configLayout() {
        containerView.flex.direction(.row)
            .alignItems(.center).paddingHorizontal(16)
            .define { flex in
                flex.addItem(icon).width(32).aspectRatio(1).cornerRadius(16)
                flex.addItem(messageLabel).marginLeft(12)
            }
    }
}
