//
//  TitleInputView.swift
//  poporazzi
//
//  Created by 김민준 on 4/4/25.
//

import UIKit
import PinLayout
import FlexLayout

final class TitleInputView: CodeBaseUI {
    
    var containerView = UIView()
    
    /// NavigationBar
    private lazy var navigationBar = NavigationBar(title: "기록 생성")
    
    /// 앨범 이름
    let titleFormLabel = FormLabel(title: "앨범 이름")
    
    /// 제목 텍스트필드
    let titleTextField = LineTextField(size: 24, placeholder: "부산 여행, 성수동 데이트")
    
    /// 세부 옵션 라벨
    let detailOptionLabel = FormLabel(title: "앨범 저장 옵션")
    
    /// 앨범에 스크린샷 포함 스위치
    let containScreenshotSwitch = FormSwitch(title: "스크린샷 포함")
    
    /// 키보드 전용 뷰
    let keyboardAccessoryView = UIView()
    
    /// 모든 정보 수정 가능 라벨
    let allInfoCanChangeAnytimeSubLabel: UILabel = {
        let label = UILabel(
            "모든 정보는 언제든지 수정이 가능해요",
            size: 14,
            color: .subLabel
        )
        label.textAlignment = .center
        return label
    }()
    
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
        
        keyboardAccessoryView.pin.width(bounds.width).height(88)
        keyboardAccessoryView.flex.layout()
        
        titleTextField.action(.setupInputAccessoryView(keyboardAccessoryView))
    }
}

// MARK: - Layout

extension TitleInputView {
    
    func configLayout() {
        containerView.flex
            .direction(.column)
            .define { flex in
                flex.addItem(navigationBar)
                
                flex.addItem().direction(.column).paddingHorizontal(20).define { flex in
                    flex.addItem(titleFormLabel).marginTop(16)
                    flex.addItem(titleTextField).marginTop(10)
                    
                    flex.addItem(detailOptionLabel).marginTop(32)
                    flex.addItem(containScreenshotSwitch).marginTop(8)
                }
            }
        
        keyboardAccessoryView.flex.direction(.column).justifyContent(.end).define { flex in
            flex.grow(1)
            flex.addItem(allInfoCanChangeAnytimeSubLabel).marginHorizontal(20)
            flex.addItem(actionButton).marginTop(16)
        }
    }
}
