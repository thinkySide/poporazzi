//
//  FolderListView.swift
//  poporazzi
//
//  Created by 김민준 on 5/30/25.
//

import UIKit
import PinLayout
import FlexLayout

final class FolderListView: CodeBaseUI {
    
    var containerView = UIView()
    
    /// NavigationBar
    private lazy var navigationBar = NavigationBar()
    
    let albumCollectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: CollectionViewLayout.albumTwoColumns
        )
        collectionView.backgroundColor = .white
        collectionView.register(
            MyAlbumListCell.self,
            forCellWithReuseIdentifier: MyAlbumListCell.identifier
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

extension FolderListView {
    
    enum Action {
        
    }
    
    func action(_ action: Action) {
        
    }
}

// MARK: - Layout

extension FolderListView {
    
    func configLayout() {
        containerView.flex.direction(.column).define { flex in
            flex.addItem(navigationBar)
            
            flex.addItem().grow(1).define { flex in
                flex.addItem(albumCollectionView).position(.absolute).top(0).horizontally(0).bottom(38)
            }
        }
    }
}
