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
    private lazy var navigationBar = NavigationBar(leading: backButton)
    
    let backButton = NavigationButton(buttonType: .back)
    
    let albumCollectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: CollectionViewLayout.folderListLayout
        )
        collectionView.backgroundColor = .white
        collectionView.register(
            FolderListCell.self,
            forCellWithReuseIdentifier: FolderListCell.identifier
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
        containerView.pin.top(pin.safeArea).horizontally().bottom()
        containerView.flex.layout()
    }
}

// MARK: - Action

extension FolderListView {
    
    enum Action {
        case setTitle(String)
    }
    
    func action(_ action: Action) {
        switch action {
        case let .setTitle(title):
            navigationBar.action(.updateTitle(title))
        }
    }
}

// MARK: - Layout

extension FolderListView {
    
    func configLayout() {
        containerView.flex.direction(.column).define { flex in
            flex.addItem(navigationBar)
            
            flex.addItem().grow(1).marginTop(8).define { flex in
                flex.addItem(albumCollectionView).position(.absolute).all(0)
            }
        }
    }
}
