//
//  TabBar.swift
//  poporazzi
//
//  Created by 김민준 on 5/23/25.
//

import UIKit
import PinLayout
import FlexLayout

final class TabBar: CodeBaseUI {
    
    var containerView = UIView()
    
    let albumListButton: UIButton = {
        let button = UIButton()
        let symbol = UIImage(symbol: .albumList, size: 22, weight: .black)
        button.setImage(symbol, for: .normal)
        button.tintColor = .subLabel
        return button
    }()
    
    let recordButton: UIButton = {
        let button = UIButton()
        button.tintColor = .subLabel
        button.clipsToBounds = true
        return button
    }()
    
    let settingsButton: UIButton = {
        let button = UIButton()
        let symbol = UIImage(symbol: .setting, size: 22, weight: .black)
        button.setImage(symbol, for: .normal)
        button.tintColor = .subLabel
        return button
    }()
    
    init() {
        super.init(frame: .zero)
        setup(color: .clear)
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

extension TabBar {
    
    enum Action {
        case updateTab(Tab, isTracking: Bool)
        case updateRecordButton(isTracking: Bool)
    }
    
    func action(_ action: Action) {
        switch action {
        case let .updateTab(tab, isTracking):
            UIView.animate(withDuration: 0.2) { [weak self] in
                guard let self else { return }
                switch tab {
                case .albumList:
                    albumListButton.alpha = 1
                    recordButton.alpha = isTracking ? 0.3 : 1
                    settingsButton.alpha = 0.3
                    
                case .record:
                    albumListButton.alpha = 0.3
                    recordButton.alpha = 1
                    settingsButton.alpha = 0.3
                    
                case .settings:
                    albumListButton.alpha = 0.3
                    recordButton.alpha = isTracking ? 0.3 : 1
                    settingsButton.alpha = 1
                }
            }
            
        case let .updateRecordButton(isTracking):
            if isTracking {
                let symbol = UIImage(symbol: .record, size: 22, weight: .black)
                recordButton.setImage(symbol, for: .normal)
                
            } else {
                let symbol = UIImage(resource: .recordStart)
                recordButton.setImage(symbol, for: .normal)
            }
        }
    }
}

// MARK: - Layout

extension TabBar {
    
    func configLayout() {
        let height: CGFloat = 48
        containerView.flex.height(height)
            .direction(.row)
            .justifyContent(.center)
            .alignItems(.center)
            .paddingHorizontal(20)
            .define { flex in
                flex.addItem(albumListButton).grow(1)
                flex.addItem(recordButton).grow(1)
                flex.addItem(settingsButton).grow(1)
            }
    }
}
