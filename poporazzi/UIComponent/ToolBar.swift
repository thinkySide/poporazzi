//
//  ToolBar.swift
//  poporazzi
//
//  Created by 김민준 on 5/4/25.
//

import UIKit
import PinLayout
import FlexLayout

final class ToolBar: CodeBaseUI {
    
    var containerView = UIView()
    
    let tapGesture = UITapGestureRecognizer()
    
    /// 툴바 제목 라벨
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .setDovemayo(16)
        label.textColor = .mainLabel
        label.textAlignment = .center
        return label
    }()
    
    private let leadingView: UIView
    private let trailingView: UIView
    
    init(
        title: String = "",
        leading: UIView = UIView(),
        trailing: UIView = UIView()
    ) {
        self.titleLabel.text = title
        self.leadingView = leading
        self.trailingView = trailing
        super.init(frame: .zero)
        setup(color: .brandTertiary)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.pin.all(pin.safeArea)
        containerView.flex.layout()
        containerView.addStroke([.top], color: .line, thickness: 1.5)
    }
}

// MARK: - Action

extension ToolBar {
    
    enum Action {
        case updateTitle(String)
    }
    
    func action(_ action: Action) {
        switch action {
        case .updateTitle(let title):
            titleLabel.flex.markDirty()
            titleLabel.text = title
        }
    }
}

// MARK: - Layout

extension ToolBar {
    
    func configLayout() {
        let bottomPadding: CGFloat = 16
        containerView.flex.height(88)
            .direction(.row)
            .justifyContent(.center)
            .alignItems(.center)
            .paddingHorizontal(20)
            .paddingBottom(bottomPadding)
            .define { flex in
                flex.addItem()
                flex.addItem(titleLabel).position(.absolute).alignSelf(.center).horizontally(32).marginBottom(bottomPadding)
                flex.addItem(leadingView)
                flex.addItem().grow(1)
                flex.addItem(trailingView)
            }
    }
}
