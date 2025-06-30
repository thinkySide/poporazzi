//
//  MediaDetailView.swift
//  poporazzi
//
//  Created by 김민준 on 5/26/25.
//

import UIKit
import PinLayout
import FlexLayout

final class MediaDetailView: CodeBaseUI {
    
    var containerView = UIView()
    
    /// 로딩 인디케이터
    private let loadingIndicator = LoadingIndicator()
    
    /// NavigationBar
    private lazy var navigationBar = NavigationBar(
        leading: backButton,
        center: navigationCenterView,
        trailing: mediaCountLabel
    )
    
    /// 뒤로가기 버튼
    let backButton = NavigationButton(buttonType: .back)
    
    let navigationCenterView = UIView()
    
    let dayCountLabel: UILabel = {
        let label = UILabel(size: 18, color: .mainLabel)
        label.textAlignment = .center
        return label
    }()
    
    let dateLabel: UILabel = {
        let label = UILabel(size: 14, color: .subLabel)
        label.textAlignment = .center
        return label
    }()
    
    /// 개수 라벨
    private let mediaCountLabel: UILabel = {
        let label = UILabel(size: 16, color: .subLabel)
        label.textAlignment = .right
        return label
    }()
    
    var mediaCollectionView = UICollectionView(frame: .zero, collectionViewLayout: .init())
    
    let toolBarView = UIView()
    
    let centerToolBarView = UIView()
    
    /// 즐겨찾기 버튼
    let favoriteButton = ToolBarButton(.favorite)
    
    /// 앨범에서 제외 버튼
    let excludeButton = ToolBarButton(.title(String(localized: "앨범에서 제외")))
    
    /// 더보기 버튼
    let seemoreButton = ToolBarButton(.seemore)
    
    /// 삭제 버튼
    let removeButton = ToolBarButton(.remove)
    
    init() {
        super.init(frame: .zero)
        setup()
        addSubview(loadingIndicator)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.pin.top(pin.safeArea).horizontally(pin.safeArea).bottom()
        loadingIndicator.pin.all()
        containerView.flex.layout()
        loadingIndicator.flex.layout()
    }
}

// MARK: - Action

extension MediaDetailView {
    
    enum Action {
        case setInitialIndex(Int)
        case updateDateLabel(dayCount: Int, Date)
        case updateMediaInfo(Media)
        case updateCountInfo(currentIndex: Int, totalCount: Int)
        case toggleLoading(Bool)
    }
    
    func action(_ action: Action) {
        switch action {
        case .setInitialIndex(let index):
            mediaCollectionView.isPagingEnabled = false
            let indexPath = IndexPath(row: index, section: 0)
            mediaCollectionView.scrollToItem(
                at: indexPath,
                at: .centeredHorizontally,
                animated: false
            )
            mediaCollectionView.isPagingEnabled = true
            
        case let .updateDateLabel(dayCount, date):
            if dayCount == 0 {
                dayCountLabel.isHidden = true
                dateLabel.font = .setDovemayo(15)
            } else {
                dayCountLabel.text = String(localized: "\(dayCount)일차")
                dateLabel.font = .setDovemayo(14)
            }
            dateLabel.text = date.detailFormat
            [dayCountLabel, dateLabel].forEach { $0.flex.markDirty() }
            containerView.flex.layout()
            
        case let .updateMediaInfo(media):
            favoriteButton.button.setImage(
                UIImage(symbol: media.isFavorite ? .favoriteActive : .favoriteActiveLine, size: 16, weight: .bold),
                for: .normal
            )
            
        case let .updateCountInfo(currentIndex, totalCount):
            mediaCountLabel.text = "\(currentIndex + 1)/\(totalCount)"
            mediaCountLabel.flex.markDirty()
            containerView.flex.layout()
            
        case let .toggleLoading(isActive):
            loadingIndicator.isHidden = !isActive
            loadingIndicator.action(isActive ? .start : .stop)
        }
    }
}

// MARK: - Layout

extension MediaDetailView {
    
    func configLayout() {
        containerView.flex.direction(.column).define { flex in
            flex.addItem(navigationBar)
            
            flex.addItem(mediaCollectionView)
                .grow(1)
                .marginVertical(24)
            
            flex.addItem(toolBarView)
                .paddingHorizontal(16)
                .height(80)
        }
        
        navigationCenterView.flex.direction(.column).define { flex in
            flex.addItem(dayCountLabel)
            flex.addItem(dateLabel).marginTop(2)
        }
        
        toolBarView.flex.direction(.row).justifyContent(.spaceBetween).define { flex in
            flex.addItem(favoriteButton)
            flex.addItem(centerToolBarView)
            flex.addItem(removeButton)
        }
        
        centerToolBarView.flex.direction(.row).define { flex in
            flex.addItem(excludeButton)
            flex.addItem(seemoreButton).marginLeft(8)
        }
    }
}
