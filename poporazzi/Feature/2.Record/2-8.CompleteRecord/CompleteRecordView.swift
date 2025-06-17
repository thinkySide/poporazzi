//
//  CompleteRecordView.swift
//  poporazzi
//
//  Created by 김민준 on 6/17/25.
//

import UIKit
import PinLayout
import FlexLayout

final class CompleteRecordView: CodeBaseUI {
    
    var containerView = UIView()
    
    private lazy var navigationBar = NavigationBar()
    
    private let actionbuttonView = UIView()
    
    let showAlbumButton = ActionButton(title: "앨범 보기", variation: .secondary)
    
    let backToHomeButton = ActionButton(title: "홈으로 돌아가기", variation: .secondary)
    
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

extension CompleteRecordView {
    
    enum Action {
        
        
    }
    
    func action(_ action: Action) {
        switch action {
            
        }
    }
}

// MARK: - Layout

extension CompleteRecordView {
    
    func configLayout() {
        containerView.flex.direction(.column).define { flex in
            flex.addItem(navigationBar)
        }
        
        actionbuttonView.flex.direction(.row).justifyContent(.spaceBetween).define { flex in
            flex.addItem(showAlbumButton).grow(1).maxWidth(50%)
            flex.addItem(backToHomeButton).grow(1).maxWidth(50%).marginLeft(12)
        }
    }
}
