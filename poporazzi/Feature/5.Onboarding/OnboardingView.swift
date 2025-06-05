//
//  OnboardingView.swift
//  poporazzi
//
//  Created by 김민준 on 6/4/25.
//

import UIKit
import PinLayout
import FlexLayout

final class OnboardingView: CodeBaseUI {
    
    var containerView = UIView()
    
    private lazy var navigationBar = NavigationBar()
    
    private let titleLabel: UILabel = {
        let label = UILabel(size: 26, color: .mainLabel)
        label.numberOfLines = 2
        label.textAlignment = .center
        label.setLine(alignment: .center, spacing: 8)
        return label
    }()
    
    var screenshotCollectionView = UICollectionView(frame: .zero, collectionViewLayout: .init())
    
    let actionButton = ActionButton(title: "다음으로", variataion: .secondary)
    
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

extension OnboardingView {
    
    enum Action {
        case updateTitleLabel(NSMutableAttributedString)
    }
    
    func action(_ action: Action) {
        switch action {
        case let .updateTitleLabel(title):
            titleLabel.attributedText = title
        }
    }
}

// MARK: - Layout

extension OnboardingView {
    
    func configLayout() {
        containerView.flex.direction(.column).define { flex in
            flex.addItem(navigationBar)
            
            flex.addItem(titleLabel).marginTop(8)
            
            flex.addItem(screenshotCollectionView)
                .grow(1)
                .marginVertical(24)
            
            flex.addItem(actionButton).width(120).alignSelf(.center)
        }
    }
}
