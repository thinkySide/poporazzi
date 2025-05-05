//
//  ExcludeRecordView.swift
//  poporazzi
//
//  Created by 김민준 on 5/5/25.
//

import UIKit
import PinLayout
import FlexLayout

final class ExcludeRecordView: CodeBaseUI {
    
    var containerView = UIView()
    
    let tapGesture = UITapGestureRecognizer()
    
    /// NavigationBar
    private lazy var navigationBar = NavigationBar(
        title: "제외된 기록",
        leading: backButton,
        trailing: selectButton
    )
    
    /// 뒤로 가기 버튼
    let backButton = NavigationButton(
        buttonType: .systemIcon(.dismiss, size: 12, weight: .bold),
        variation: .secondary
    )
    
    /// 선택 버튼
    let selectButton = NavigationButton(
        buttonType: .text("선택"),
        variation: .secondary
    )
    
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

extension ExcludeRecordView {
    
    func configLayout() {
        containerView.flex.direction(.column).define { flex in
            flex.addItem(navigationBar)
            
            flex.addItem().direction(.row).paddingHorizontal(20).define { flex in
                
            }
        }
    }
}
