//
//  FormDatePicker.swift
//  poporazzi
//
//  Created by 김민준 on 4/17/25.
//

import UIKit
import PinLayout
import FlexLayout

final class FormDatePicker: CodeBaseUI {
    
    var containerView = UIView()
    
    /// 탭 제스쳐
    let tapGesture = UITapGestureRecognizer()
    
    /// 날짜 라벨
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .setDovemayo(18)
        label.textColor = .subLabel
        return label
    }()
    
    /// 오른쪽 화살표
    private let chevronRight = UIImageView(
        symbol: .right,
        size: 13,
        weight: .semibold,
        tintColor: .subLabel
    )
    
    init() {
        super.init(frame: .zero)
        setup()
        action(.updateDate(.now))
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

extension FormDatePicker {
    
    enum Action {
        case updateDate(Date)
    }
    
    func action(_ action: Action) {
        switch action {
        case let .updateDate(date):
            dateLabel.text = date.startDateFullFormat
            dateLabel.flex.markDirty()
        }
    }
}

// MARK: - Layout

extension FormDatePicker {
    
    func configLayout() {
        containerView.flex.direction(.row).define { flex in
            flex.addItem(dateLabel)
            flex.addItem().grow(1)
            flex.addItem(chevronRight)
        }
    }
}
