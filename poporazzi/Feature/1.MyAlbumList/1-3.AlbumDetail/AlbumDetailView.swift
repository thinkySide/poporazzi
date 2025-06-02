//
//  AlbumDetailView.swift
//  poporazzi
//
//  Created by 김민준 on 5/27/25.
//

import UIKit
import PinLayout
import FlexLayout

final class AlbumDetailView: CodeBaseUI {
    
    var containerView = UIView()
    
    /// NavigationBar
    private lazy var navigationBar = NavigationBar(
        leading: backButton,
        trailing: navigationTrailingButtons
    )
    
    /// 뒤로 가기 버튼
    let backButton = NavigationButton(buttonType: .back)
    
    /// 오른쪽 버튼들
    private let navigationTrailingButtons: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    /// 더보기 버튼
    let seemoreButton = NavigationButton(buttonType: .seemore)
    
    /// 선택 버튼
    let selectButton = NavigationButton(buttonType: .text("선택"), variation: .secondary)
    
    /// 선택 취소 버튼
    let selectCancelButton: NavigationButton = {
        let button = NavigationButton(buttonType: .text("취소"), variation: .secondary)
        button.isHidden = true
        return button
    }()
    
    /// 미디어 컬렉션 뷰
    let mediaCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: .init())
        collectionView.backgroundColor = .white
        return collectionView
    }()
    
    /// ToolBar
    lazy var toolBar: ToolBar = {
        let toolBar = ToolBar(
            leading: favoriteToolBarButton,
            centers: [excludeToolBarButton, seemoreToolBarButton],
            trailing: removeToolBarButton
        )
        return toolBar
    }()
    
    /// 즐겨찾기 툴 바 버튼
    let favoriteToolBarButton = ToolBarButton(.favorite)
    
    /// 앨범에서 제외 툴 바 버튼
    let excludeToolBarButton = ToolBarButton(.title("앨범에서 제외"))
    
    /// 더보기 툴 바 버튼
    let seemoreToolBarButton = ToolBarButton(.seemore)
    
    /// 삭제 툴 바 버튼
    let removeToolBarButton = ToolBarButton(.remove)
    
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

extension AlbumDetailView {
    
    enum Action {
        case toggleSelectMode(Bool)
        case updateTitle(isShown: Bool, String)
        case updateSelectedCount(Int)
        case updateShouldFavorite(Bool)
    }
    
    func action(_ action: Action) {
        switch action {
        case let .toggleSelectMode(isSelectMode):
            mediaCollectionView.allowsSelection = false
            mediaCollectionView.allowsSelection = true
            mediaCollectionView.allowsMultipleSelection = isSelectMode
            [seemoreButton, selectButton].forEach { $0.isHidden = isSelectMode }
            [selectCancelButton].forEach { $0.isHidden = !isSelectMode }
            
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut) { [weak self] in
                self?.mediaCollectionView.contentInset.bottom = isSelectMode ? 80 : 24
                self?.toolBar.transform = isSelectMode ?
                CGAffineTransform(translationX: 0, y: -128) : .identity
            }
            
        case let .updateTitle(isShown, title):
            self.navigationBar.action(.updateTitle(title))
            UIView.animate(withDuration: 0.2) {
                if isShown {
                    self.navigationBar.titleLabel.alpha = 1
                } else {
                    self.navigationBar.titleLabel.alpha = 0
                }
            }
            
        case let .updateSelectedCount(count):
            if count == 0 {
                toolBar.action(.updateTitle("기록을 선택해주세요"))
                [favoriteToolBarButton, excludeToolBarButton, seemoreToolBarButton, removeToolBarButton].forEach {
                    $0.action(.toggleDisabled(true))
                }
            } else {
                let attributedText = NSMutableAttributedString()
                    .tint("\(count)장", color: .brandPrimary)
                    .tint("의 기록이 선택됨", color: .mainLabel)
                
                toolBar.action(.updateTitle(AttributedString(attributedText)))
                [favoriteToolBarButton, excludeToolBarButton, seemoreToolBarButton, removeToolBarButton].forEach {
                    $0.action(.toggleDisabled(false))
                }
            }
            
        case let .updateShouldFavorite(isFavorite):
            let symbol = UIImage(symbol: isFavorite ? .favoriteActive : .favoriteRemove, size: 16, weight: .bold)
            favoriteToolBarButton.button.setImage(symbol, for: .normal)
        }
    }
}

// MARK: - Layout

extension AlbumDetailView {
    
    func configLayout() {
        containerView.flex.direction(.column).define { flex in
            flex.addItem(navigationBar)
            
            flex.addItem().grow(1).marginTop(12).define { flex in
                flex.addItem(mediaCollectionView).position(.absolute).all(0)
            }
            
            flex.addItem(toolBar).position(.absolute)
                .horizontally(0).bottom(-128)
        }
        
        navigationTrailingButtons.flex.direction(.row).define { flex in
            flex.addItem(seemoreButton)
            flex.addItem(selectButton).marginLeft(8)
            flex.addItem(selectCancelButton).position(.absolute).right(0)
        }
    }
}
