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
    
    let tapGesture = UITapGestureRecognizer()
    
    /// 네비게이션 제목 라벨
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .setDovemayo(16)
        label.textColor = .mainLabel
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

extension NavigationBar {
    
    func configLayout() {
        let height: CGFloat = 48
        containerView.flex.height(height)
            .direction(.row)
            .justifyContent(.center)
            .alignItems(.center)
            .paddingHorizontal(20)
            .define { flex in
                flex.addItem(titleLabel).position(.absolute).alignSelf(.center)
                flex.addItem(leadingView)
                flex.addItem().grow(1)
                flex.addItem(trailingView)
            }
    }
}
