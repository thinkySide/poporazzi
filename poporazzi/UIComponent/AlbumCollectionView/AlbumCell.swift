//
//  AlbumCell.swift
//  poporazzi
//
//  Created by 김민준 on 5/23/25.
//

import UIKit
import PinLayout
import FlexLayout

final class AlbumCell: UICollectionViewCell {
    
    static let identifier = "AlbumCell"
    
    var containerView = UIView()
    
    private let thumbnailContainer = UIView()
    
    /// 미디어 썸네일
    private let thumbnail: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    /// 제목 라벨
    private let titleLabel = UILabel(size: 15, color: .mainLabel)
    
    /// 시작 날짜 라벨
    private let startDateLabel = UILabel(size: 13, color: .subLabel)
    
    /// 개수 라벨
    private let countLabel: UILabel = {
        let label = UILabel(size: 13, color: .white)
        label.backgroundColor = .black.withAlphaComponent(0.3)
        label.textAlignment = .center
        label.clipsToBounds = true
        return label
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
        thumbnail.image = nil
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

extension AlbumCell {
    
    enum Action {
        case setThumbnail(UIImage?)
        case setAlbumInfo(Album)
    }
    
    func action(_ action: Action) {
        switch action {
        case let .setThumbnail(image):
            if let image {
                self.thumbnail.image = image
            } else {
                self.thumbnail.backgroundColor = .brandTertiary
            }
            
        case let .setAlbumInfo(album):
            titleLabel.text = album.title
            startDateLabel.text = album.startDate.startDateFormat
            countLabel.text = "\(album.estimateCount)"
        }
    }
}

// MARK: - Layout

extension AlbumCell {
    
    func configLayout() {
        containerView.flex.define { flex in
            flex.addItem(thumbnailContainer).width(.infinity).aspectRatio(1)
            flex.addItem(titleLabel).marginTop(8).horizontally(2)
            flex.addItem(startDateLabel).marginTop(4).horizontally(2)
        }
        
        thumbnailContainer.flex.define { flex in
            flex.addItem(thumbnail).cornerRadius(16).grow(1)
            flex.addItem(countLabel).paddingHorizontal(8).height(24).minWidth(28)
                .position(.absolute).right(10).bottom(10)
                .cornerRadius(12)
        }
    }
}
