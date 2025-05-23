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
        let symbol = UIImage(symbol: .albumList, size: 20, weight: .black)
        button.setImage(symbol, for: .normal)
        return button
    }()
    
    let recordButton: UIButton = {
        let button = UIButton()
        let symbol = UIImage(symbol: .record, size: 20, weight: .black)
        button.setImage(symbol, for: .normal)
        return button
    }()
    
    let settingsButton: UIButton = {
        let button = UIButton()
        let symbol = UIImage(symbol: .setting, size: 20, weight: .black)
        button.setImage(symbol, for: .normal)
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
