//
//  InfoLabel.swift
//  poporazzi
//
//  Created by 김민준 on 5/5/25.
//

import UIKit
import PinLayout
import FlexLayout

final class InfoLabel: CodeBaseUI {
    
    var containerView = UIView()
    
    /// 정보 아이콘
    private let infoIcon = UIImageView(
        symbol: .info,
        size: 12,
        weight: .black,
        tintColor: .subLabel
    )
    
    /// 정보 라벨
    private let label: UILabel = {
        let label = UILabel()
        label.font = .setDovemayo(14)
        label.textColor = .subLabel
        return label
    }()
    
    init(title: String) {
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

// MARK: - Layout

extension InfoLabel {
    
    func configLayout() {
        containerView.flex.direction(.row).define { flex in
            flex.addItem(infoIcon)
            flex.addItem(label).marginLeft(4)
        }
    }
}
