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
    
    private let leadings: UIView
    private let centers: [UIView]
    private let trailings: UIView
    
    private let buttons = UIView()
    private let centerView = UIView()
    
    init(
        title: String = "",
        leading: UIView = UIView(),
        centers: [UIView] = [],
        trailing: UIView = UIView()
    ) {
        self.titleLabel.text = title
        self.leadings = leading
        self.centers = centers
        self.trailings = trailing
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
        containerView.layer.shadowOffset = .init(width: 0, height: -1)
        containerView.layer.shadowColor = UIColor.mainLabel.cgColor
        containerView.layer.shadowOpacity = 0.08
        containerView.layer.shadowRadius = 10
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
        containerView.flex.height(128)
            .direction(.column)
            .paddingHorizontal(16)
            .define { flex in
                flex.addItem(titleLabel).marginTop(16)
                flex.addItem(buttons).marginTop(16)
            }
        
        centerView.flex.direction(.row).define { flex in
            for (index, view) in centers.enumerated() {
                flex.addItem(view)
                    .marginLeft(index > 0 ? 8 : 0)
            }
        }
        
        buttons.flex.direction(.row).justifyContent(.spaceBetween).define { flex in
            flex.addItem(leadings)
            flex.addItem(centerView)
            flex.addItem(trailings)
        }
    }
}
