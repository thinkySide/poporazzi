//
//  FolderEditView.swift
//  poporazzi
//
//  Created by 김민준 on 6/3/25.
//

import UIKit
import PinLayout
import FlexLayout

final class FolderEditView: CodeBaseUI {
    
    var containerView = UIView()
    
    let tapGesture = UITapGestureRecognizer()
    
    /// NavigationBar
    private lazy var navigationBar = NavigationBar(
        title: "폴더 수정",
        leading: backButton,
        trailing: saveButton
    )
    
    /// 뒤로 가기 버튼
    let backButton = NavigationButton(buttonType: .back)
    
    /// 저장 버튼
    let saveButton = NavigationButton(
        buttonType: .text("저장"),
        variation: .secondary
    )
    
    /// 제목 양식 라벨
    let titleFormLabel = FormLabel(title: "폴더 이름")
    
    /// 제목 텍스트필드
    let titleTextField = LineTextField(size: 20, placeholder: "플레이스홀더")
    
    init() {
        super.init(frame: .zero)
        setup()
        addGestureRecognizer(tapGesture)
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

extension FolderEditView {
    
    enum Action {
        case toggleSaveButton(Bool)
    }
    
    func action(_ action: Action) {
        switch action {
        case let .toggleSaveButton(isValid):
            saveButton.action(.toggleDisabled(!isValid))
        }
    }
}

// MARK: - Layout

extension FolderEditView {
    
    func configLayout() {
        containerView.flex.direction(.column).define { flex in
            flex.addItem(navigationBar)
            
            flex.addItem().paddingHorizontal(20).define { flex in
                flex.addItem(titleFormLabel).marginTop(24)
                flex.addItem(titleTextField).marginTop(12)
            }
        }
    }
}
