//
//  AlbumEditView.swift
//  poporazzi
//
//  Created by 김민준 on 4/17/25.
//

import UIKit
import PinLayout
import FlexLayout

final class AlbumEditView: CodeBaseUI {
    
    var containerView = UIView()
    
    let tapGesture = UITapGestureRecognizer()
    
    /// NavigationBar
    private lazy var navigationBar = NavigationBar(
        title: "앨범 수정",
        leading: backButton,
        trailing: saveButton
    )
    
    /// 뒤로 가기 버튼
    let backButton = NavigationButton(
        buttonType: .systemIcon(.dismiss, size: 12, weight: .bold),
        variation: .secondary
    )
    
    /// 저장 버튼
    let saveButton = NavigationButton(
        buttonType: .text("저장"),
        variation: .secondary
    )
    
    /// 제목 양식 라벨
    let titleFormLabel = FormLabel(title: "앨범 이름")
    
    /// 제목 텍스트필드
    let titleTextField = LineTextField(size: 20, placeholder: "플레이스홀더")
    
    /// 시작날짜 양식 라벨
    let startDateFormLabel = FormLabel(title: "시작 날짜")
    
    /// 시작날짜 피커
    let startDatePicker = FormDatePicker()
    
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

// MARK: - Layout

extension AlbumEditView {
    
    func configLayout() {
        containerView.flex.direction(.column).define { flex in
            flex.addItem(navigationBar)
            
            flex.addItem().direction(.column).paddingHorizontal(20).define { flex in
                flex.addItem().marginTop(24).define { flex in
                    flex.addItem(titleFormLabel)
                    flex.addItem(titleTextField).marginTop(12)
                }
                
                flex.addItem().marginTop(32).define { flex in
                    flex.addItem(startDateFormLabel)
                    flex.addItem(startDatePicker).marginTop(12)
                }
            }
        }
    }
}
