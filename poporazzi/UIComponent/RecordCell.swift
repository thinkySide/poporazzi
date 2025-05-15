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
    private let videoOverlay: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        return view
    }()
    
    /// 선택 전용 오버레이
    private let selectOverlay: UIView = {
        let view = UIView()
        view.backgroundColor = .white.withAlphaComponent(0.4)
        view.isHidden = true
        return view
    }()
    
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
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.mainLabel.withAlphaComponent(0.4).cgColor]
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
    
    /// 셀 선택 아이콘
    private let checkIcon: UIImageView = {
        let imageView = UIImageView(image: .checkIcon)
        imageView.isHidden = true
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(containerView)
        contentView.addSubview(videoOverlay)
        contentView.addSubview(selectOverlay)
        videoOverlay.layer.addSublayer(videoGradientLayer)
        configLayout()
        [containerView, videoOverlay, selectOverlay, thumbnail, videoDurationLabel]
            .forEach { $0.isUserInteractionEnabled = false }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.pin.all()
        videoOverlay.pin.all()
        selectOverlay.pin.all()
        videoGradientLayer.frame = videoOverlay.bounds
        containerView.flex.layout()
        videoOverlay.flex.layout()
        selectOverlay.flex.layout()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnail.image = nil
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                selectOverlay.isHidden = false
                checkIcon.isHidden = false
            } else {
                selectOverlay.isHidden = true
                checkIcon.isHidden = true
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
        case setImage(UIImage?)
        case setMediaType(MediaType)
    }
    
    func action(_ action: Action) {
        switch action {
        case let .setImage(image):
            if let image {
                self.thumbnail.image = image
            } else {
                self.backgroundColor = .brandTertiary
            }
            
        case let .setMediaType(mediaType):
            switch mediaType {
            case .photo:
                videoDurationLabel.text = ""
                videoOverlay.isHidden = true
                videoDurationLabel.flex.markDirty()
                
            case let .video(_, _, duration):
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
        let cornerRadius: CGFloat = 8
        containerView.flex.define { flex in
            flex.addItem(thumbnail).cornerRadius(cornerRadius).grow(1)
            flex.addItem(checkIcon).position(.absolute).top(8).left(8)
        }
        
        videoOverlay.flex.cornerRadius(cornerRadius).define { flex in
            flex.addItem(videoDurationLabel).position(.absolute).bottom(6).right(10)
        }
    }
}
