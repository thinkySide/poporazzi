//
//  MediaDetailCell.swift
//  poporazzi
//
//  Created by 김민준 on 5/27/25.
//

import UIKit
import PinLayout
import FlexLayout

final class MediaDetailCell: UICollectionViewCell {
    
    static let identifier = "MediaDetailCell"
    
    var containerView = UIView()
    
    private let thumbnailContainer = UIView()
    
    private let indicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        return indicator
    }()
    
    /// 미디어 이미지
    private let mediaImage: UIImageView = {
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
        mediaImage.image = nil
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

extension MediaDetailCell {
    
    enum Action {
        case setImage(UIImage)
        case toggleLoading(Bool)
    }
    
    func action(_ action: Action) {
        switch action {
        case let .setImage(image):
            mediaImage.image = image
            
        case let .toggleLoading(bool):
            indicator.isHidden = !bool
            bool ? indicator.startAnimating() : indicator.stopAnimating()
        }
    }
}

// MARK: - Layout

extension MediaDetailCell {
    
    func configLayout() {
        containerView.flex.define { flex in
            flex.addItem(mediaImage).grow(1)
            flex.addItem(indicator).position(.absolute).alignSelf(.center).top(50%)
        }
    }
}
