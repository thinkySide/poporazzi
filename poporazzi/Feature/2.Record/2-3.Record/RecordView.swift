//
//  RecordView.swift
//  poporazzi
//
//  Created by 김민준 on 4/5/25.
//

import UIKit
import PinLayout
import FlexLayout

final class RecordView: CodeBaseUI {
    
    var containerView = UIView()
    
    /// 로딩 인디케이터
    private let loadingIndicator = LoadingIndicator()
    
    /// Header
    let headerView = UIView()
    
    /// NavigationBar
    private lazy var navigationBar = NavigationBar(
        leading: titleLabel,
        trailing: navigationTrailingButtons
    )
    
    private let titleLabel = UILabel("기록 중", size: 20, color: .mainLabel)
    
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
    
    /// 기록 종료 버튼
    let finishRecordButton = NavigationButton(buttonType: .text("기록 종료"), variation: .primary)
    
    /// 선택 취소 버튼
    let selectCancelButton: NavigationButton = {
        let button = NavigationButton(buttonType: .text("취소"), variation: .secondary)
        button.isHidden = true
        return button
    }()
    
    /// ToolBar
    lazy var toolBar: ToolBar = {
        let toolBar = ToolBar(
            leading: favoriteToolBarButton,
            centers: [excludeToolBarButton, seemoreToolBarButton],
            trailing: removeToolBarButton
        )
        toolBar.alpha = 0
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
    
    /// 앨범 제목 라벨
    private let albumTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .setDovemayo(24)
        label.textColor = .mainLabel
        return label
    }()
    
    /// 총 기록 개수 라벨
    private let totalRecordCountLabel = UILabel("총 0장", size: 16, color: .subLabel)
    
    private let emptyView = UIView()
    
    /// 앱 아이콘
    private let appIconImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(resource: .appIcon))
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    /// 촬영된 사진이 없을 때 라벨
    private let emptyLabel = UILabel("지금부터 포포라치가 기록을 시작할게요!", size: 16, color: .mainLabel)
    
    /// 직접 촬영 라벨
    let selfShootingInfoLabel = SymbolLabel(
        symbol: .check,
        tintColor: .brandPrimary
    )
    
    /// 다운로드 라벨
    let downloadInfoLabel = SymbolLabel(
        symbol: .check,
        tintColor: .brandPrimary
    )
    
    /// 스크린샷 라벨
    let screenshotInfoLabel = SymbolLabel(
        symbol: .check,
        tintColor: .brandPrimary
    )
    
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
        addSubview(loadingIndicator)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.pin.top(pin.safeArea).left().right().bottom()
        loadingIndicator.pin.all()
        containerView.flex.layout()
        loadingIndicator.flex.layout()
    }
}

// MARK: - Action

extension RecordView {
    
    enum Action {
        case updateTitleLabel(String)
        case updateInfoLabel(Album)
        case toggleEmptyLabel(Bool)
        case toggleSelectMode(Bool)
        case toggleFavoriteMode(Bool)
        case updateSelectedCountLabel(Int)
        case toggleLoading(Bool)
    }
    
    func action(_ action: Action) {
        defer { containerView.flex.layout() }
        switch action {
        case let .updateTitleLabel(text):
            albumTitleLabel.text = text
            albumTitleLabel.flex.markDirty()
            containerView.flex.layout()
            
        case let .updateInfoLabel(album):
            let fetchOption = album.mediaFetchOption.title
            
            if album.mediaFilterOption.isContainSelfShooting {
                selfShootingInfoLabel.action(.updateLabel("직접 촬영한 \(fetchOption)"))
                selfShootingInfoLabel.action(.toggleSymbol(true))
                selfShootingInfoLabel.flex.display(.flex)
            } else {
                selfShootingInfoLabel.action(.updateLabel(""))
                selfShootingInfoLabel.action(.toggleSymbol(false))
                selfShootingInfoLabel.flex.display(.none)
            }
            
            if album.mediaFilterOption.isContainDownload {
                downloadInfoLabel.action(.updateLabel("다운로드한 \(fetchOption)"))
                downloadInfoLabel.action(.toggleSymbol(true))
                downloadInfoLabel.flex.display(.flex)
            } else {
                downloadInfoLabel.action(.updateLabel(""))
                downloadInfoLabel.action(.toggleSymbol(false))
                downloadInfoLabel.flex.display(.none)
            }
            
            if album.mediaFilterOption.isContainScreenshot && album.mediaFetchOption != .video {
                screenshotInfoLabel.action(.updateLabel("스크린샷"))
                screenshotInfoLabel.action(.toggleSymbol(true))
                screenshotInfoLabel.flex.display(.flex)
            } else {
                screenshotInfoLabel.action(.updateLabel(""))
                screenshotInfoLabel.action(.toggleSymbol(false))
                screenshotInfoLabel.flex.display(.none)
            }
            
        case let .toggleEmptyLabel(isEmpty):
            let display: Flex.Display = isEmpty ? .flex : .none
            headerView.flex.display(display)
            emptyView.flex.display(display)
            
            if !isEmpty {
                selfShootingInfoLabel.action(.toggleSymbol(false))
                downloadInfoLabel.action(.toggleSymbol(false))
                screenshotInfoLabel.action(.toggleSymbol(false))
            }
            
        case let .toggleSelectMode(bool):
            recordCollectionView.allowsSelection = false
            recordCollectionView.allowsSelection = true // 셀 선택 상태 초기화용
            recordCollectionView.allowsMultipleSelection = bool
            [seemoreButton, selectButton, finishRecordButton].forEach { $0.isHidden = bool }
            [selectCancelButton].forEach { $0.isHidden = !bool }
            UIView.animate(withDuration: 0.2) { [weak self] in
                self?.recordCollectionView.contentInset.bottom = bool ? 80 : 24
                self?.toolBar.alpha = bool ? 1 : 0
            }
            
        case let .toggleFavoriteMode(bool):
            let symbol = UIImage(symbol: bool ? .favoriteActive : .favoriteRemove, size: 16, weight: .bold)
            favoriteToolBarButton.button.setImage(symbol, for: .normal)
            
        case let .updateSelectedCountLabel(count):
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
            
        case let .toggleLoading(isActive):
            loadingIndicator.isHidden = !isActive
            loadingIndicator.action(isActive ? .start : .stop)
        }
    }
}

// MARK: - Layout

extension RecordView {
    
    func configLayout() {
        containerView.flex.direction(.column).define { flex in
            flex.addItem(navigationBar)
            
            flex.addItem(headerView)
                .marginTop(12)
                .paddingHorizontal(20)
            
            flex.addItem().grow(1).marginTop(12).define { flex in
                flex.addItem(recordCollectionView).position(.absolute).all(0)
            }
            
            flex.addItem(emptyView)
                .position(.absolute)
                .alignSelf(.center)
                .alignItems(.center)
                .top(35%)
            
            flex.addItem(toolBar).position(.absolute).horizontally(0).bottom(0)
        }
        
        headerView.flex.direction(.row).justifyContent(.spaceBetween).define { flex in
            flex.addItem(albumTitleLabel).marginRight(4).shrink(1)
            flex.addItem(totalRecordCountLabel)
        }
        
        emptyView.flex.define { flex in
            flex.addItem(appIconImageView).size(CGSize(width: 56, height: 56))
            flex.addItem(emptyLabel).marginTop(16)
            flex.addItem(selfShootingInfoLabel).marginTop(12)
            flex.addItem(downloadInfoLabel).marginTop(10)
            flex.addItem(screenshotInfoLabel).marginTop(10)
        }
        
        navigationTrailingButtons.flex.direction(.row).define { flex in
            flex.addItem(seemoreButton)
            flex.addItem(selectButton).marginLeft(8)
            flex.addItem(finishRecordButton).marginLeft(8)
            flex.addItem(selectCancelButton).position(.absolute).right(0)
        }
    }
}
