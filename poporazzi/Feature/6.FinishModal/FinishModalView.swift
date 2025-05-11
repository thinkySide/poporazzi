//
//  FinishModalView.swift
//  poporazzi
//
//  Created by 김민준 on 5/11/25.
//

import UIKit
import PinLayout
import FlexLayout

final class FinishModalView: CodeBaseUI {
    
    var containerView = UIView()
    
    /// 기록 종료 라벨
    private let finishLabel: UILabel = {
        let label = UILabel()
        label.text = "기록을 종료할까요?"
        label.font = .setDovemayo(18)
        label.textColor = .mainLabel
        return label
    }()
    
    /// 하나로 저장 라디오 버튼
    let saveAsSingleRadioButton = RadioButton(
        title: "하나로 저장",
        sub: "모든 사진이 하나의 앨범으로 저장돼요",
        variation: .selected
    )
    
    /// 일차별 저장 라디오 버튼
    let saveByDayRadioButton = RadioButton(
        title: "일차별 저장",
        sub: "모든 일차별로 앨범을 생성 후 한 폴더에 저장돼요",
        variation: .deselected
    )
    
    /// 종료 버튼
    let finishButton = ActionButton(title: "기록 종료하기", variataion: .primary)
    
    /// 취소 버튼
    let cancelButton = CancelButton()
    
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

// MARK: - Layout

extension FinishModalView {
    
    func configLayout() {
        containerView.flex.direction(.column).paddingHorizontal(20).define { flex in
            flex.addItem(finishLabel).marginTop(28).alignSelf(.center)
            
            flex.addItem(saveAsSingleRadioButton).marginTop(24)
            flex.addItem(saveByDayRadioButton).marginTop(16)
            
            flex.addItem(finishButton).marginTop(32)
            flex.addItem(cancelButton).marginTop(8).alignSelf(.center)
        }
    }
}
