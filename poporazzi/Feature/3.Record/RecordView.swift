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
    
    /// 앱 아이콘
    private let appIconImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(resource: .appIcon))
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    /// 촬영된 사진이 없을 때 라벨
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "지금부터 촬영한 모든 사진과\n영상을 포포라치가 기록할 거에요!"
        label.numberOfLines = 3
        label.setLine(alignment: .center, spacing: 8)
        label.font = .setDovemayo(16)
        label.textColor = .mainLabel
        return label
    }()
    
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
            
        case let .toggleEmptyLabel(isEmpty):
            let display: Flex.Display = isEmpty ? .flex : .none
            appIconImageView.flex.display(display)
            emptyLabel.flex.display(display)
            headerView.flex.display(display)
            
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
            
            flex.addItem().direction(.column)
                .position(.absolute).alignSelf(.center).alignItems(.center).top(40%)
                .define { flex in
                    flex.addItem(appIconImageView).size(CGSize(width: 56, height: 56))
                    flex.addItem(emptyLabel).marginTop(16)
                }
            
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
        
        navigationTrailingButtons.flex.direction(.row).define { flex in
            flex.addItem(seemoreButton)
            flex.addItem(selectButton).marginLeft(8)
            flex.addItem(finishRecordButton).marginLeft(8)
            flex.addItem(selectCancelButton).position(.absolute).right(0)
        }
    }
}
