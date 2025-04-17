//
//  MomentEditView.swift
//  poporazzi
//
//  Created by 김민준 on 4/17/25.
//

import UIKit
import PinLayout
import FlexLayout

final class MomentEditView: CodeBaseUI {
    
    var containerView = UIView()
    
    /// NavigationBar
    private lazy var navigationBar = NavigationBar(
        title: "기록 수정",
        leading: backButton,
        trailing: saveButton
    )
    
    /// 뒤로 가기 버튼
    let backButton = NavigationButton(
        buttonType: .systemIcon(.dismiss, size: 12, weight: .bold),
        colorType: .secondary
    )
    
    /// 저장 버튼
    let saveButton = NavigationButton(
        buttonType: .text("저장"),
        colorType: .secondary
    )
    
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

extension MomentEditView {
    
    enum Action {
        
    }
    
    func action(_ action: Action) {
        
    }
}

// MARK: - Layout

extension MomentEditView {
    
    func configLayout() {
        containerView.flex.direction(.column).define { flex in
            flex.addItem(navigationBar)
        }
    }
}
