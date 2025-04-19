//
//  MomentTitleInputView.swift
//  poporazzi
//
//  Created by 김민준 on 4/4/25.
//

import UIKit
import PinLayout
import FlexLayout

final class MomentTitleInputView: CodeBaseUI {
    
    var containerView = UIView()
    
    /// 상단 라벨
    private let headerLabel: UILabel = {
        let label = UILabel()
        label.text = "어떤 순간을 기록하고 싶으신가요?"
        label.textColor = .mainLabel
        label.font = .setDovemayo(22)
        return label
    }()
    
    /// 제목 텍스트필드
    let titleTextField = LineTextField(size: 24, placeholder: "제주도 우정 여행, 성수동 데이트")
    
    /// 액션 버튼
    let actionButton = TextFieldActionButton(title: "기록 시작하기")
    
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
        titleTextField.action(.setupInputAccessoryView(actionButton))
    }
}

// MARK: - Action

extension MomentTitleInputView {
    
    enum Action {
        
    }
    
    func action(_ action: Action) {
        
    }
}

// MARK: - Layout

extension MomentTitleInputView {
    
    func configLayout() {
        containerView.flex
            .direction(.column)
            .define { flex in
                flex.addItem().direction(.column).paddingHorizontal(20).define { flex in
                    flex.addItem(headerLabel).marginTop(64)
                    flex.addItem(titleTextField).marginTop(32)
                }
            }
        
        actionButton.pin.height(56)
    }
}
