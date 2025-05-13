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
    private lazy var navigationBar = NavigationBar()
    
    /// 메인 라벨
    let mainLabel = UILabel(
        "어떤 순간을 기록하고 싶으신가요?",
        size: 22,
        color: .mainLabel
    )
    
    /// 앨범 이름
    let titleFormLabel = FormLabel(title: "앨범 이름")
    
    /// 제목 텍스트필드
    let titleTextField = LineTextField(size: 24, placeholder: "부산 여행, 성수동 데이트")
    
    /// 앨범 이름 수정 가능 라벨
    let albumNameCanChangeAnytimeSubLabel: UILabel = {
        let label = UILabel(
            "앨범 이름은 언제든 수정이 가능해요",
            size: 14,
            color: .subLabel
        )
        return label
    }()
    
    /// 키보드 전용 뷰
    let keyboardAccessoryView = UIView()
    
    /// 다음 버튼
    let nextButton = ActionButton(title: "다음", variataion: .primary)
    
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
                    flex.addItem(mainLabel).marginTop(16)
                    
                    flex.addItem(titleFormLabel).marginTop(40)
                    flex.addItem(titleTextField).marginTop(10)
                    flex.addItem(albumNameCanChangeAnytimeSubLabel).marginTop(10)
                }
            }
        
        keyboardAccessoryView.flex.direction(.column).justifyContent(.end).define { flex in
            flex.addItem(nextButton).marginBottom(12).marginHorizontal(20)
        }
    }
}
