//
//  MomentRecordView.swift
//  poporazzi
//
//  Created by 김민준 on 4/5/25.
//

import UIKit
import PinLayout
import FlexLayout

final class MomentRecordView: CodeBaseUIView {
    
    var containerView = UIView()
    
    private lazy var navigationBar = NavigationBar(
        leading: leading,
        center: centerView,
        trailing: trailing
    )
    
    private let leading: UILabel = {
        let label = UILabel()
        label.text = "leading"
        return label
    }()
    
    private let centerView: UILabel = {
        let label = UILabel()
        label.text = "center"
        return label
    }()
    
    private let trailing: UILabel = {
        let label = UILabel()
        label.text = "trailing"
        return label
    }()
    
    init() {
        super.init(frame: .zero)
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.pin.all(pin.safeArea)
        containerView.flex.layout()
    }
}

// MARK: - Action

extension MomentRecordView {
    
    enum Action {
        
    }
    
    func action(_ action: Action) {
        switch action {
            
        }
    }
}

// MARK: - Layout

extension MomentRecordView {
    
    func configLayout() {
        containerView.flex
            .direction(.column)
            .define { flex in
                flex.addItem(navigationBar)
            }
    }
}
