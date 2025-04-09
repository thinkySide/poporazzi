//
//  MomentRecordView.swift
//  poporazzi
//
//  Created by 김민준 on 4/5/25.
//

import UIKit
import PinLayout
import FlexLayout

final class MomentRecordView: CodeBaseUI {
    
    var containerView = UIView()
    
    /// NavigationBar
    private lazy var navigationBar = NavigationBar(
        trailing: finishRecordButton
    )
    
    /// 기록 종료 버튼
    let finishRecordButton = NavigationButton(buttonType: .text("기록 종료"))
    
    /// 앨범 제목 라벨
    private let albumTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .setPretendard(.bold, 22)
        label.textColor = .mainLabel
        return label
    }()
    
    /// 트래킹 시작 날짜 라벨
    private let trackingStartDateLabel: UILabel = {
        let label = UILabel()
        label.font = .setPretendard(.medium, 14)
        label.textColor = .subLabel
        return label
    }()
    
    /// 총 사진 개수 라벨
    private let totalPhotoCountLabel: UILabel = {
        let label = UILabel()
        label.font = .setPretendard(.semiBold, 15)
        label.textColor = .subLabel
        return label
    }()
    
    /// 앨범 컬렉션 뷰
    lazy var albumCollectionView: UICollectionView = {
        let refreshControl = UIRefreshControl()
        refreshControl.endRefreshing()
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: compositionalLayout
        )
        collectionView.refreshControl = refreshControl
        collectionView.register(
            MomentRecordCell.self,
            forCellWithReuseIdentifier: MomentRecordCell.identifier
        )
        return collectionView
    }()
    
    private let compositionalLayout: UICollectionViewCompositionalLayout = {
        
        // 1. 기본값 변수 저장
        let numberOfRows: CGFloat = 3
        let itemInset: CGFloat = 2
        
        // 2. 아이템(Cell) 설정
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalHeight(1),
            heightDimension: .fractionalHeight(1)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .init(top: 0, leading: 0, bottom: itemInset, trailing: itemInset)
        let lastItem = NSCollectionLayoutItem(layoutSize: itemSize)
        lastItem.contentInsets = .init(top: 0, leading: 0, bottom: itemInset, trailing: 0)
        
        // 3. 그룹 설정
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalWidth(1 / numberOfRows)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item, item, lastItem]
        )
        
        // 4. 섹션 설정
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        return UICollectionViewCompositionalLayout(section: section)
    }()
    
    init() {
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.pin.top(pin.safeArea).left().right().bottom()
        containerView.flex.layout()
    }
}

// MARK: - Action

extension MomentRecordView {
    
    enum Action {
        case setAlbumTitleLabel(String)
        case setTrackingStartDateLabel(String)
        case setTotalImageCountLabel(Int)
    }
    
    func action(_ action: Action) {
        defer { containerView.flex.layout() }
        switch action {
        case let .setAlbumTitleLabel(title):
            albumTitleLabel.text = title
            albumTitleLabel.flex.markDirty()
            
        case let .setTrackingStartDateLabel(text):
            trackingStartDateLabel.text = text
            trackingStartDateLabel.flex.markDirty()
            
        case let .setTotalImageCountLabel(count):
            totalPhotoCountLabel.text = "총 \(count)장"
            totalPhotoCountLabel.flex.markDirty()
        }
    }
}

// MARK: - Layout

extension MomentRecordView {
    
    func configLayout() {
        containerView.flex.direction(.column)
            .define { flex in
                flex.addItem(navigationBar)
                
                flex.addItem().direction(.column).paddingHorizontal(20)
                    .define { flex in
                        flex.addItem(albumTitleLabel)
                        
                        flex.addItem().direction(.row).marginTop(10).define { flex in
                            flex.addItem(trackingStartDateLabel)
                            flex.addItem().grow(1)
                            flex.addItem(totalPhotoCountLabel)
                        }
                    }
                
                flex.addItem(albumCollectionView).grow(1).marginTop(24)
            }
    }
}
