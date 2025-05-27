//
//  DetailCell.swift
//  poporazzi
//
//  Created by 김민준 on 5/27/25.
//

import UIKit
import PinLayout
import FlexLayout

final class DetailCell: UICollectionViewCell {
    
    static let identifier = "DetailCell"
    
    var containerView = UIView()
    
    private let thumbnailContainer = UIView()
    
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

extension DetailCell {
    
    enum Action {
        case setImage(UIImage?)
    }
    
    func action(_ action: Action) {
        switch action {
        case let .setImage(image):
            if let image {
                self.mediaImage.image = image
            } else {
                self.mediaImage.backgroundColor = .brandTertiary
            }
        }
    }
}

// MARK: - Layout

extension DetailCell {
    
    func configLayout() {
        containerView.flex.define { flex in
            flex.addItem(mediaImage).grow(1)
        }
    }
}
