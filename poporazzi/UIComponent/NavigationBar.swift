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
    
    /// 네비게이션 제목 라벨
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .setDovemayo(16)
        label.textColor = .mainLabel
        label.textAlignment = .center
        return label
    }()
    
    private let leadingView: UIView
    private let centerView: UIView?
    private let trailingView: UIView
    
    init(
        title: String = "",
        leading: UIView = UIView(),
        center: UIView? = nil,
        trailing: UIView = UIView()
    ) {
        self.titleLabel.text = title
        self.leadingView = leading
        self.centerView = center
        self.trailingView = trailing
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

extension NavigationBar {
    
    enum Action {
        case updateTitle(String)
    }
    
    func action(_ action: Action) {
        switch action {
        case let .updateTitle(title):
            titleLabel.text = title
            titleLabel.flex.markDirty()
            containerView.flex.layout()
        }
    }
}

// MARK: - Layout

extension NavigationBar {
    
    func configLayout() {
        containerView.flex.height(48)
            .direction(.row)
            .justifyContent(.spaceBetween)
            .alignItems(.center)
            .paddingHorizontal(20)
            .define { flex in
                flex.addItem(leadingView)
                
                if let centerView {
                    flex.addItem(centerView).position(.absolute).horizontally(100)
                } else {
                    flex.addItem(titleLabel).position(.absolute).horizontally(140)
                }
                
                flex.addItem(trailingView)
            }
    }
}
