//
//  DetailView.swift
//  poporazzi
//
//  Created by 김민준 on 5/26/25.
//

import UIKit
import PinLayout
import FlexLayout

final class DetailView: CodeBaseUI {
    
    var containerView = UIView()
    
    /// NavigationBar
    private lazy var navigationBar = NavigationBar(leading: backButton)
    
    /// 뒤로가기 버튼
    let backButton = NavigationButton(buttonType: .back)
    
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

extension DetailView {
    
    enum Action {
        
    }
    
    func action(_ action: Action) {
        switch action {
            
        }
    }
}

// MARK: - Layout

extension DetailView {
    
    func configLayout() {
        containerView.flex.direction(.column).define { flex in
            flex.addItem(navigationBar)
        }
    }
}
