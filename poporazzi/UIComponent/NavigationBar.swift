//
//  NavigationBar.swift
//  poporazzi
//
//  Created by 김민준 on 4/5/25.
//

import UIKit
import PinLayout
import FlexLayout

final class NavigationBar: CodeBaseUI {
    
    var containerView = UIView()
    
    private let leadingView: UIView
    private let centerView: UIView
    private let trailingView: UIView
    
    init(
        leading: UIView = UIView(),
        center: UIView = UIView(),
        trailing: UIView = UIView()
    ) {
        self.leadingView = leading
        self.centerView = center
        self.trailingView = trailing
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

extension NavigationBar {
    
    enum Action {
        
    }
    
    func action(_ action: Action) {
        switch action {
            
        }
    }
}

// MARK: - Layout

extension NavigationBar {
    
    func configLayout() {
        let height: CGFloat = 48
        containerView.flex.height(height)
            .direction(.row)
            .justifyContent(.center)
            .alignItems(.center)
            .paddingHorizontal(20)
            .define { flex in
                flex.addItem(leadingView)
                flex.addItem().grow(1)
                flex.addItem(centerView)
                flex.addItem().grow(1)
                flex.addItem(trailingView)
            }
    }
}
