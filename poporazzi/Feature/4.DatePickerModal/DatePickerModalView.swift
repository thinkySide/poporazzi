//
//  DatePickerModalView.swift
//  poporazzi
//
//  Created by 김민준 on 4/18/25.
//

import UIKit
import PinLayout
import FlexLayout

final class DatePickerModalView: CodeBaseUI {
    
    var containerView = UIView()
    
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

extension DatePickerModalView {
    
    func configLayout() {
        containerView.flex.direction(.column).define { flex in
            
        }
    }
}
