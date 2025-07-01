//
//  OnboardingCell.swift
//  poporazzi
//
//  Created by 김민준 on 6/4/25.
//

import UIKit
import PinLayout
import FlexLayout

final class OnboardingCell: UICollectionViewCell {
    
    static let identifier = "OnboardingCell"
    
    var containerView = UIView()
    
    /// 스크린샷
    private let screenshot: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(containerView)
        configLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.pin.all()
        containerView.flex.layout()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        screenshot.image = nil
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                
            } else {
                
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Action

extension OnboardingCell {
    
    enum Action {
        case setImage(UIImage)
    }
    
    func action(_ action: Action) {
        switch action {
        case let .setImage(image): screenshot.image = image
        }
    }
}

// MARK: - Layout

extension OnboardingCell {
    
    func configLayout() {
        containerView.flex.define { flex in
            flex.addItem(screenshot).grow(1)
        }
    }
}
