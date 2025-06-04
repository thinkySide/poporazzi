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
    
    private let screenshot: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let actionButton = ActionButton(title: "다음으로", variataion: .secondary)
    
    init() {
        super.init(frame: .zero)
        setup()
        
        titleLabel.text = "앨범 정리, 3단계로\n쉽고 편하게 정리해요"
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
        
    }
    
    func action(_ action: Action) {
        
    }
}

// MARK: - Layout

extension OnboardingView {
    
    func configLayout() {
        containerView.flex.direction(.column).alignItems(.center).define { flex in
            flex.addItem(navigationBar)
            flex.addItem(titleLabel).marginTop(8)
            flex.addItem().grow(1)
            flex.addItem(actionButton).width(120)
        }
    }
}
