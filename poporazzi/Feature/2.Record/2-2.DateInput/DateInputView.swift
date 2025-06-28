//
//  DateInputView.swift
//  poporazzi
//
//  Created by 김민준 on 5/13/25.
//

import UIKit
import PinLayout
import FlexLayout

final class DateInputView: CodeBaseUI {
    
    var containerView = UIView()
    
    /// NavigationBar
    private lazy var navigationBar = NavigationBar(leading: backButton)
    
    /// 뒤로가기 버튼
    let backButton = NavigationButton(buttonType: .back)
    
    /// 메인 라벨
    let mainLabel = UILabel(
        "앨범을 기록할 시간대를 선택해주세요",
        size: 22,
        color: .mainLabel
    )
    
    /// 서브 라벨
    let subLabel = UILabel(
        "선택한 시간 사이의 항목을 기록할게요",
        size: 16,
        color: .subLabel
    )
    
    /// 시작시간 양식 라벨
    let startDateFormLabel = FormLabel(title: "시작 시간")
    
    /// 시작시간 피커
    let startDatePicker = FormDatePicker()
    
    /// 종료시간 양식 라벨
    let endDateFormLabel = FormLabel(title: "종료 시간")
    
    /// 종료시간 피커
    let endDatePicker = FormDatePicker(title: "~ 기록 종료 시 까지")
    
    /// 모든 정보 수정 가능 라벨
    private let allInfoCanChangeAnytimeSubLabel: UILabel = {
        let label = UILabel(
            "모든 정보는 언제든지 수정이 가능해요",
            size: 14,
            color: .subLabel
        )
        label.textAlignment = .center
        return label
    }()
    
    /// 시작 버튼
    let startButton = ActionButton(title: "기록 시작하기", variation: .primary)
    
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

// MARK: - Action

extension DateInputView {
    
    enum Action {
        
    }
    
    func action(_ action: Action) {
        switch action {
            
        }
    }
}

// MARK: - Layout

extension DateInputView {
    
    func configLayout() {
        containerView.flex
            .direction(.column)
            .define { flex in
                flex.addItem(navigationBar).marginTop(16)
                
                flex.addItem().direction(.column).paddingHorizontal(20).define { flex in
                    flex.addItem(mainLabel).marginTop(16)
                    flex.addItem(subLabel).marginTop(8)
                    
                    flex.addItem(startDateFormLabel).marginTop(40)
                    flex.addItem(startDatePicker).marginTop(6)
                    
                    flex.addItem(endDateFormLabel).marginTop(24)
                    flex.addItem(endDatePicker).marginTop(6)
                }
                
                flex.addItem().grow(1)
                
                flex.addItem().direction(.column).paddingHorizontal(20).define { flex in
                    flex.addItem(allInfoCanChangeAnytimeSubLabel).marginBottom(12)
                    flex.addItem(startButton).marginBottom(16)
                }
            }
    }
}
