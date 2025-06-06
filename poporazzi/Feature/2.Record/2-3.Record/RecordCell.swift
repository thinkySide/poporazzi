//
//  RecordCell.swift
//  poporazzi
//
//  Created by 김민준 on 4/7/25.
//

import UIKit
import PinLayout
import FlexLayout

final class RecordCell: UICollectionViewCell {
    
    static let identifier = "RecordCell"
    
    var containerView = UIView()
    
    /// 기본 오버레이
    private let defaultoverlay: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.alpha = 0
        return view
    }()
    
    /// 오버레이 전용 그라디언트 레이어
    private let overlayGradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.mainLabel.withAlphaComponent(0.4).cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        return gradientLayer
    }()
    
    /// 선택 전용 오버레이
    private let selectOverlay: UIView = {
        let view = UIView()
        view.backgroundColor = .white.withAlphaComponent(0.4)
        view.alpha = 0
        return view
    }()
    
    /// 미디어 썸네일
    private let thumbnail: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    /// 영상 길이 라벨
    private let videoDurationLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .setDovemayo(14)
        return label
    }()
    
    /// 셀 선택 아이콘
    private let checkIcon: UIImageView = {
        let imageView = UIImageView(image: .checkIcon)
        imageView.alpha = 0
        return imageView
    }()
    
    /// 셀 즐겨찾기 아이콘
    private let favoriteIcon: UIImageView = {
        let imageView = UIImageView(
            symbol: .favoriteActive,
            size: 12,
            weight: .bold,
            tintColor: .white
        )
        imageView.alpha = 0
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        containerView.clipsToBounds = true
        contentView.addSubview(containerView)
        contentView.addSubview(defaultoverlay)
        contentView.addSubview(selectOverlay)
        defaultoverlay.layer.addSublayer(overlayGradientLayer)
        configLayout()
        [containerView, defaultoverlay, selectOverlay, thumbnail, videoDurationLabel]
            .forEach { $0.isUserInteractionEnabled = false }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.pin.all()
        defaultoverlay.pin.all()
        selectOverlay.pin.all()
        overlayGradientLayer.frame = defaultoverlay.bounds
        containerView.flex.layout()
        defaultoverlay.flex.layout()
        selectOverlay.flex.layout()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnail.image = nil
    }
    
    override var isSelected: Bool {
        didSet {
            guard NameSpace.isSelectionMode else { return }
            
            if isSelected {
                selectOverlay.alpha = 1
                checkIcon.alpha = 1
            } else {
                selectOverlay.alpha = 0
                checkIcon.alpha = 0
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Action

extension RecordCell {
    
    enum Action {
        case setMedia(Media, UIImage?)
    }
    
    func action(_ action: Action) {
        switch action {
        case let .setMedia(media, image):
            if let image {
                self.thumbnail.image = image
            } else {
                containerView.backgroundColor = .brandTertiary
            }
            
            switch media.mediaType {
            case .photo:
                videoDurationLabel.text = ""
                defaultoverlay.alpha = media.isFavorite ? 1 : 0
                favoriteIcon.alpha = media.isFavorite ? 1 : 0
                videoDurationLabel.flex.markDirty()
                
            case let .video(_, _, duration):
                videoDurationLabel.text = duration.videoDurationFormat
                defaultoverlay.alpha = 1
                favoriteIcon.alpha = media.isFavorite ? 1 : 0
                videoDurationLabel.flex.markDirty()
            }
        }
    }
}

// MARK: - Layout

extension RecordCell {
    
    func configLayout() {
        let cornerRadius: CGFloat = 8
        containerView.flex.cornerRadius(cornerRadius).define { flex in
            flex.addItem(thumbnail).cornerRadius(cornerRadius).grow(1)
            flex.addItem(checkIcon).position(.absolute).top(8).left(8)
        }
        
        defaultoverlay.flex.cornerRadius(cornerRadius).define { flex in
            flex.addItem(favoriteIcon).position(.absolute).bottom(8).left(10)
            flex.addItem(videoDurationLabel).position(.absolute).bottom(6).right(10)
        }
    }
}
