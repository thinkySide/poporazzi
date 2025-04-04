//
//  MomentTitleInputView.swift
//  poporazzi
//
//  Created by 김민준 on 4/4/25.
//

import UIKit
import PinLayout
import FlexLayout

final class MomentTitleInputView: CodeBaseUIView {
    
    var containerView = UIView()
    
    /// 상단 라벨
    private let headerLabel: UILabel = {
        let label = UILabel()
        label.text = "어떤 순간을 기록하고 싶으신가요?"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        return label
    }()
    
    /// 제목 텍스트필드
    private let titleTextField = LineTextField(
        placeholder: "제주도 우정 여행, 성수동 데이트"
    )
    
    init() {
        super.init(frame: .zero)
        setup()
    }
    
    override func layoutSubviews() {
        containerView.pin.all(pin.safeArea)
        containerView.flex.layout()
    }
}

// MARK: - Action

extension MomentTitleInputView {
    
    enum Action {
        
    }
    
    func action(_ action: Action) {
        switch action {
            
        }
    }
}

// MARK: - Layout

extension MomentTitleInputView {
    
    func configLayout() {
        containerView.flex.direction(.column).paddingHorizontal(20).define { flex in
            flex.addItem(headerLabel).marginTop(40)
            flex.addItem(titleTextField).marginTop(40)
        }
    }
}
