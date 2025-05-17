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
        datePicker.preferredDatePickerStyle = .inline
        datePicker.locale = Locale(identifier: "ko-KR")
        datePicker.maximumDate = .now
        datePicker.tintColor = .brandPrimary
        datePicker.minuteInterval = 10
        return datePicker
    }()
    
    let actionbuttonView = UIView()
    
    let cancelButton = ActionButton(title: "취소", variataion: .secondary)
    
    let confirmButton = ActionButton(title: "시작 시간 저장", variataion: .primary)
    
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
            flex.addItem(datePicker).position(.absolute).top(12).horizontally(20).bottom(24)
            flex.addItem(actionbuttonView).position(.absolute).bottom(8).horizontally(20)
        }
        
        actionbuttonView.flex.direction(.row).justifyContent(.spaceBetween).define { flex in
            flex.addItem(cancelButton).grow(1).maxWidth(50%)
            flex.addItem(confirmButton).grow(1).maxWidth(50%).marginLeft(12)
        }
    }
}
