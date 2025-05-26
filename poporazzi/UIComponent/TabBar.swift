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
    
    var selectedTab = Tab.albumList
    
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
        setup(color: .white)
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
        case updateTab(Tab)
        case updateRecordButton(isTracking: Bool)
    }
    
    func action(_ action: Action) {
        switch action {
        case let .updateTab(tab):
            selectedTab = tab
            UIView.animate(withDuration: 0.2, delay: 0, options: .allowUserInteraction) { [weak self] in
                guard let self else { return }
                switch tab {
                case .albumList:
                    albumListButton.alpha = 1
                    recordButton.alpha = 0.3
                    settingsButton.alpha = 0.3
                    
                case .record:
                    albumListButton.alpha = 0.3
                    recordButton.alpha = 1
                    settingsButton.alpha = 0.3
                    
                case .settings:
                    albumListButton.alpha = 0.3
                    recordButton.alpha = 0.3
                    settingsButton.alpha = 1
                }
            }
            
        case let .updateRecordButton(isTracking):
            if isTracking {
                let symbol = UIImage(symbol: .record, size: 22, weight: .black)
                recordButton.setImage(symbol, for: .normal)
                switch selectedTab {
                case .albumList, .settings: recordButton.alpha = 0.3
                case .record: recordButton.alpha = 1
                }
                recordButton.flex.markDirty()
                containerView.flex.layout()
                
            } else {
                let symbol = UIImage(resource: .recordStart)
                recordButton.setImage(symbol, for: .normal)
                recordButton.alpha = 1
                recordButton.flex.markDirty()
                containerView.flex.layout()
            }
        }
    }
}

// MARK: - Layout

extension TabBar {
    
    func configLayout() {
        let buttonHeight: CGFloat = 48
        containerView.flex.height(NameSpace.tabBarSize)
            .direction(.row)
            .paddingHorizontal(20)
            .define { flex in
                flex.addItem(albumListButton).grow(1).height(buttonHeight)
                flex.addItem(recordButton).grow(1).height(buttonHeight)
                flex.addItem(settingsButton).grow(1).height(buttonHeight)
            }
    }
}
