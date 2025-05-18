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
        trailing: navigationTrailingButtons
    )
    
    /// 오른쪽 버튼들
    private let navigationTrailingButtons: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    /// 더보기 버튼
    let seemoreButton: NavigationButton = {
        let button = NavigationButton(buttonType: .seemore)
        button.button.showsMenuAsPrimaryAction = true
        return button
    }()
    
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
            leading: excludeButton,
            trailing: removeButton
        )
        toolBar.isHidden = true
        return toolBar
    }()
    
    /// 앨범에서 제외 버튼
    let excludeButton = ToolBarButton(title: "앨범에서 제외")
    
    /// 삭제 버튼
    let removeButton = ToolBarButton(title: "삭제")
    
    /// 앨범 제목 라벨
    private let albumTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .setDovemayo(24)
        label.textColor = .mainLabel
        return label
    }()
    
    /// 시작 날짜 라벨
    private let startDateLabel: UILabel = {
        let label = UILabel()
        label.font = .setDovemayo(16)
        label.textColor = .subLabel
        return label
    }()
    
    /// 총 기록 개수 라벨
    private let totalRecordCountLabel: UILabel = {
        let label = UILabel()
        label.font = .setDovemayo(16)
        label.textColor = .subLabel
        return label
    }()
    
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
            collectionViewLayout: CollectionViewLayout.headerSection
        )
        collectionView.backgroundColor = .white
        collectionView.allowsSelection = false
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
        case updateStartDateLabel(String)
        case updateInfoLabel(Album)
        case toggleEmptyLabel(Bool)
        case toggleSelectMode(Bool)
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
            
        case let .updateStartDateLabel(text):
            startDateLabel.text = text
            startDateLabel.flex.markDirty()
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
            recordCollectionView.contentInset.bottom = bool ? 56 : 0
            recordCollectionView.allowsSelection = bool
            recordCollectionView.allowsMultipleSelection = bool
            [seemoreButton, selectButton, finishRecordButton].forEach { $0.isHidden = bool }
            [selectCancelButton, toolBar].forEach { $0.isHidden = !bool }
            
        case let .updateSelectedCountLabel(count):
            if count == 0 {
                toolBar.action(.updateTitle("기록 선택"))
                [excludeButton, removeButton].forEach {
                    $0.alpha = 0.3
                    $0.isUserInteractionEnabled = false
                }
            } else {
                toolBar.action(.updateTitle("\(count)장의 기록이 선택됨"))
                [excludeButton, removeButton].forEach {
                    $0.alpha = 1
                    $0.isUserInteractionEnabled = true
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
                .marginTop(4)
                .paddingHorizontal(20)
            
            flex.addItem().grow(1).marginTop(12).define { flex in
                flex.addItem(recordCollectionView).position(.absolute).all(0)
            }
            
            flex.addItem(emptyView)
                .position(.absolute)
                .alignSelf(.center)
                .alignItems(.center)
                .top(40%)
            
            flex.addItem(toolBar).position(.absolute).horizontally(0).bottom(0)
        }
        
        headerView.flex.direction(.column).define { flex in
            flex.addItem(albumTitleLabel)
            
            flex.addItem().direction(.row).marginTop(6).define { flex in
                flex.addItem(startDateLabel)
                flex.addItem().grow(1)
                flex.addItem(totalRecordCountLabel)
            }
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
