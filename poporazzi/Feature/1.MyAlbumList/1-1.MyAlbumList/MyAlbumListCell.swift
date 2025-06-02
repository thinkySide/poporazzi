//
//  MyAlbumListCell.swift
//  poporazzi
//
//  Created by 김민준 on 5/23/25.
//

import UIKit
import PinLayout
import FlexLayout

final class MyAlbumListCell: UICollectionViewCell {
    
    static let identifier = "MyAlbumListCell"
    
    var containerView = UIView()
    
    private let thumbnailContainer: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        return view
    }()
    
    /// 앨범 썸네일
    private let albumThumbnail = UIImageView()
    
    /// 첫 번째 폴더 썸네일
    private let folderThumbnailFirst = UIImageView()
    
    /// 두 번째 폴더 썸네일
    private let folderThumbnailSecond = UIImageView()
    
    /// 세 번째 폴더 썸네일
    private let folderThumbnailThird = UIImageView()
    
    /// 네 번째 폴더 썸네일
    private let folderThumbnailFourth = UIImageView()
    
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
        [albumThumbnail,
         folderThumbnailFirst, folderThumbnailSecond,
         folderThumbnailThird, folderThumbnailFourth]
            .forEach {
                $0.contentMode = .scaleAspectFill
                $0.clipsToBounds = true
            }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.pin.all()
        containerView.flex.layout()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        [albumThumbnail,
         folderThumbnailFirst, folderThumbnailSecond,
         folderThumbnailThird, folderThumbnailFourth]
            .forEach { $0.image = nil }
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

extension MyAlbumListCell {
    
    enum Action {
        case setAlbum(Album, [UIImage?])
    }
    
    func action(_ action: Action) {
        switch action {
        case let .setAlbum(album, thumbnailList):
            let isHidden = album.albumType == .folder
            albumThumbnail.isHidden = isHidden
            [folderThumbnailFirst, folderThumbnailSecond,
             folderThumbnailThird, folderThumbnailFourth].forEach {
                $0.isHidden = !isHidden
                $0.backgroundColor = .brandTertiary
            }
            
            switch album.albumType {
            case .album:
                if let thumbnail = thumbnailList.first {
                    self.albumThumbnail.image = thumbnail
                } else {
                    self.albumThumbnail.backgroundColor = .brandTertiary
                }
                
            case .folder:
                for i in thumbnailList.indices {
                    switch i {
                    case 0: folderThumbnailFirst.image = thumbnailList[0]
                    case 1: folderThumbnailSecond.image = thumbnailList[1]
                    case 2: folderThumbnailThird.image = thumbnailList[2]
                    case 3: folderThumbnailFourth.image = thumbnailList[3]
                    default: break
                    }
                }
            }
            
            titleLabel.text = album.title
            startDateLabel.text = album.creationDate.startDateFormat
            countLabel.text = "\(album.estimateCount)"
            [titleLabel, startDateLabel, countLabel].forEach { $0.flex.markDirty() }
            containerView.flex.layout()
        }
    }
}

// MARK: - Layout

extension MyAlbumListCell {
    
    func configLayout() {
        containerView.flex.define { flex in
            flex.addItem(thumbnailContainer).width(.infinity).aspectRatio(1)
            flex.addItem(titleLabel).marginTop(8).horizontally(2)
            flex.addItem(startDateLabel).marginTop(4).horizontally(2)
        }
        
        thumbnailContainer.flex.cornerRadius(16).define { flex in
            flex.addItem(albumThumbnail).grow(1)
                .position(.absolute)
                .vertically(0).horizontally(0)
            
            let spacing: CGFloat = 4
            flex.addItem().direction(.column).justifyContent(.spaceBetween).alignItems(.stretch).define { flex in
                flex.addItem().direction(.row).justifyContent(.spaceBetween).define { flex in
                    flex.addItem(folderThumbnailFirst).width(50%).aspectRatio(1)
                    flex.addItem().width(spacing)
                    flex.addItem(folderThumbnailSecond).width(50%).aspectRatio(1)
                }
                
                flex.addItem().direction(.row).justifyContent(.spaceBetween).marginTop(spacing).define { flex in
                    flex.addItem(folderThumbnailThird).width(50%).aspectRatio(1)
                    flex.addItem().width(spacing)
                    flex.addItem(folderThumbnailFourth).width(50%).aspectRatio(1)
                }
            }
            
            flex.addItem(countLabel)
                .paddingHorizontal(6).height(24).minWidth(28)
                .position(.absolute).right(10).bottom(10)
                .cornerRadius(12)
        }
    }
}
