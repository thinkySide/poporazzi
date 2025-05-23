//
//  AlbumListView.swift
//  poporazzi
//
//  Created by 김민준 on 5/23/25.
//

import UIKit
import PinLayout
import FlexLayout

final class AlbumListView: CodeBaseUI {
    
    var containerView = UIView()
    
    /// NavigationBar
    private lazy var navigationBar = NavigationBar()
    
    private let titleLabel = UILabel("앨범 리스트", size: 20, color: .mainLabel)
    
    let albumCollectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: CollectionViewLayout.albumTwoColumns
        )
        collectionView.backgroundColor = .white
        collectionView.register(
            RecordCell.self,
            forCellWithReuseIdentifier: AlbumCell.identifier
        )
        return collectionView
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
        containerView.pin.all(pin.safeArea)
        containerView.flex.layout()
    }
}

// MARK: - Action

extension AlbumListView {
    
    enum Action {
        
    }
    
    func action(_ action: Action) {
        
    }
}

// MARK: - Layout

extension AlbumListView {
    
    func configLayout() {
        containerView.flex.direction(.column).define { flex in
            flex.addItem(navigationBar)
            
            flex.addItem().paddingHorizontal(20).define { flex in
                flex.addItem(titleLabel)
            }
        }
    }
}
