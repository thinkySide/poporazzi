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
    
    /// 영상 전용 오버레이
    private let videoOverlay = UIView()
    
    /// 미디어 썸네일
    private let thumbnail: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    /// 영상 전용 그라디언트 레이어
    private let videoGradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.brandPrimary.withAlphaComponent(0.4).cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        return gradientLayer
    }()
    
    /// 영상 길이 라벨
    private let videoDurationLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .setDovemayo(14)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(containerView)
        contentView.addSubview(videoOverlay)
        videoOverlay.layer.addSublayer(videoGradientLayer)
        configLayout()
        [containerView, videoOverlay, thumbnail, videoDurationLabel].forEach { $0.isUserInteractionEnabled = false }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.pin.all()
         videoOverlay.pin.all()
         videoGradientLayer.frame = videoOverlay.bounds
         containerView.flex.layout()
         videoOverlay.flex.layout()
    }
    
    override var isSelected: Bool {
        didSet {
            
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Action

extension RecordCell {
    
    enum Action {
        case setImage(UIImage)
        case setMediaType(MediaType)
    }
    
    func action(_ action: Action) {
        switch action {
        case let .setImage(image):
            self.thumbnail.image = image
            
        case let .setMediaType(mediaType):
            switch mediaType {
            case .photo:
                videoDurationLabel.text = ""
                videoOverlay.isHidden = true
                videoDurationLabel.flex.markDirty()
                
            case let .video(duration):
                videoDurationLabel.text = duration.videoDurationFormat
                videoOverlay.isHidden = false
                videoDurationLabel.flex.markDirty()
            }
        }
    }
}

// MARK: - Layout

extension RecordCell {
    
    func configLayout() {
        containerView.flex.define { flex in
            flex.addItem(thumbnail)
        }
        
        videoOverlay.flex.define { flex in
            flex.addItem(videoDurationLabel).position(.absolute).bottom(6).right(10)
        }
    }
}
