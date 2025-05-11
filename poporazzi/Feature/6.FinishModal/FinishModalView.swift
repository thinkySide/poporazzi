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
    
    let confirmButton = ActionButton(title: "확인", variataion: .primary)
    
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
            
        }
    }
}
