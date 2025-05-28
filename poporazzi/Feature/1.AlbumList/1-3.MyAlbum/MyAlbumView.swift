//
//  MyAlbumView.swift
//  poporazzi
//
//  Created by 김민준 on 5/27/25.
//

import UIKit
import PinLayout
import FlexLayout

final class MyAlbumView: CodeBaseUI {
    
    var containerView = UIView()
    
    /// NavigationBar
    private lazy var navigationBar = NavigationBar(
        leading: backButton
    )
    
    /// 뒤로 가기 버튼
    let backButton = NavigationButton(buttonType: .back)
    
    /// 기록 컬렉션 뷰
    let recordCollectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: CollectionViewLayout.recordHeaderSection
        )
        collectionView.backgroundColor = .white
        collectionView.contentInset.bottom = 24
        collectionView.register(
            RecordCell.self,
            forCellWithReuseIdentifier: RecordCell.identifier
        )
        collectionView.register(
            RecordTitleHeader.self,
            forSupplementaryViewOfKind: CollectionViewLayout.mainHeaderKind,
            withReuseIdentifier: RecordTitleHeader.identifier
        )
        collectionView.register(
            RecordDateHeader.self,
            forSupplementaryViewOfKind: CollectionViewLayout.subHeaderKind,
            withReuseIdentifier: RecordDateHeader.identifier
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

// MARK: - Layout

extension MyAlbumView {
    
    func configLayout() {
        containerView.flex.direction(.column).define { flex in
            flex.addItem(navigationBar)
            
            flex.addItem().grow(1).marginTop(12).define { flex in
                flex.addItem(recordCollectionView).position(.absolute).all(0)
            }
        }
    }
}
