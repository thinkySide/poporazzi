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
    
    let tapGesture = UITapGestureRecognizer()
    
    let datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .dateAndTime
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.locale = Locale(identifier: "ko-KR")
        return datePicker
    }()
    
    let confirmButton = ActionButton(title: "확인", variataion: .secondary)
    
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
        containerView.flex.direction(.column).paddingHorizontal(20).define { flex in
            flex.addItem(datePicker).alignSelf(.center).marginTop(24)
            flex.addItem().grow(1)
            flex.addItem(confirmButton).marginBottom(8)
        }
    }
}
