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
    
    enum Variation {
        case startDate
        case endDate
        
        var sheetHeight: CGFloat {
            switch self {
            case .startDate: 504
            case .endDate: 544
            }
        }
        
        var title: String {
            switch self {
            case .startDate: "시작 시간 설정"
            case .endDate: "종료 시간 설정"
            }
        }
        
        var info: String {
            switch self {
            case .startDate: "선택한 시간부터 앨범이 기록돼요"
            case .endDate: "선택한 시간까지 앨범이 기록돼요"
            }
        }
    }
    
    var containerView = UIView()
    
    var variation: Variation
    
    private let titleLabel = UILabel(size: 18, color: .mainLabel)
    
    private let infoLabel = UILabel(size: 14, color: .subLabel)
    
    let datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .dateAndTime
        datePicker.preferredDatePickerStyle = .inline
        datePicker.locale = Locale(identifier: "ko-KR")
        datePicker.tintColor = .brandPrimary
        datePicker.minuteInterval = 10
        return datePicker
    }()
    
    let endOfRecordCheckBox = FormCheckBox("기록 종료 시 까지", variation: .deselected)
    
    private let actionbuttonView = UIView()
    
    let cancelButton = ActionButton(title: "취소", variataion: .secondary)
    
    let confirmButton = ActionButton(title: "확인", variataion: .primary)
    
    init(variation: Variation) {
        self.variation = variation
        super.init(frame: .zero)
        self.titleLabel.text = variation.title
        self.infoLabel.text = variation.info
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

extension DatePickerModalView {
    
    enum Action {
        case setupSelectableStartDateRange(endDate: Date?)
        case setupSelectableEndDateRange(startDate: Date)
        case toggleEndOfRecordCheckBox(Bool)
    }
    
    func action(_ action: Action) {
        switch action {
        case let .setupSelectableStartDateRange(endDate):
            self.datePicker.maximumDate = endDate
            
        case let .setupSelectableEndDateRange(startDate):
            self.datePicker.minimumDate = startDate
            
        case let .toggleEndOfRecordCheckBox(isActive):
            if isActive {
                self.endOfRecordCheckBox.action(.updateVariation(.selected))
                UIView.animate(withDuration: 0.2) { [weak self] in
                    self?.datePicker.isEnabled = false
                }
            } else {
                self.endOfRecordCheckBox.action(.updateVariation(.deselected))
                UIView.animate(withDuration: 0.2) { [weak self] in
                    self?.datePicker.isEnabled = true
                }
            }
        }
    }
}

// MARK: - Layout

extension DatePickerModalView {
    
    func configLayout() {
        containerView.flex.direction(.column).define { flex in
            flex.addItem(titleLabel).marginTop(28).alignSelf(.center)
            flex.addItem(infoLabel).marginTop(6).alignSelf(.center)
            flex.addItem(datePicker).marginTop(0).alignSelf(.center)
            
            if variation == .endDate {
                flex.addItem(endOfRecordCheckBox).marginTop(0).alignSelf(.center)
            }
            
            flex.addItem(actionbuttonView).marginTop(16).marginHorizontal(20)
        }
        
        actionbuttonView.flex.direction(.row).justifyContent(.spaceBetween).define { flex in
            flex.addItem(cancelButton).grow(1).maxWidth(50%)
            flex.addItem(confirmButton).grow(1).maxWidth(50%).marginLeft(12)
        }
    }
}
