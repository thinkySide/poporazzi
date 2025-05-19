//
//  ExcludeRecordView.swift
//  poporazzi
//
//  Created by 김민준 on 5/5/25.
//

import UIKit
import PinLayout
import FlexLayout

final class ExcludeRecordView: CodeBaseUI {
    
    var containerView = UIView()
    
    /// 로딩 인디케이터
    private let loadingIndicator = LoadingIndicator()
    
    /// NavigationBar
    private lazy var navigationBar = NavigationBar(
        title: "제외된 기록",
        leading: backButton,
        trailing: navigationTrailingButtons
    )
    
    /// 오른쪽 버튼들
    private let navigationTrailingButtons = UIView()
    
    /// 뒤로 가기 버튼
    let backButton = NavigationButton(buttonType: .back)
    
    /// 선택 버튼
    let selectButton = NavigationButton(
        buttonType: .text("선택"),
        variation: .secondary
    )
    
    /// 선택 취소 버튼
    let selectCancelButton: NavigationButton = {
        let button = NavigationButton(buttonType: .text("취소"), variation: .secondary)
        button.isHidden = true
        return button
    }()
    
    /// 정보 라벨
    let infoLabel = SymbolLabel(
        title: "종료 시 앨범에 저장되지 않는 기록이에요",
        symbol: .info,
        tintColor: .subLabel
    )
    
    /// 제외된 사진이 없을 때 라벨
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "제외된 기록이 없어요!"
        label.font = .setDovemayo(16)
        label.textColor = .mainLabel
        return label
    }()
    
    /// 총 제외된 기록 개수 라벨
    private let totalCountLabel: UILabel = {
        let label = UILabel()
        label.font = .setDovemayo(16)
        label.textColor = .subLabel
        return label
    }()
    
    /// 제외된 기록 컬렉션 뷰
    let recordCollectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: CollectionViewLayout.threeColumns
        )
        collectionView.backgroundColor = .white
        collectionView.allowsSelection = false
        collectionView.register(
            RecordCell.self,
            forCellWithReuseIdentifier: RecordCell.identifier
        )
        return collectionView
    }()
    
    /// ToolBar
    lazy var toolBar: ToolBar = {
        let toolBar = ToolBar(
            leading: favoriteToolBarButton,
            centers: [recoverToolBarButton, seemoreToolBarButton],
            trailing: removeToolBarButton
        )
        toolBar.isHidden = true
        return toolBar
    }()
    
    /// 즐겨찾기 툴 바 버튼
    let favoriteToolBarButton = ToolBarButton(.favorite)
    
    /// 앨범으로 복구 툴 바 버튼
    let recoverToolBarButton = ToolBarButton(.title("앨범으로 복구"))
    
    /// 더보기 툴 바 버튼
    let seemoreToolBarButton = ToolBarButton(.seemore)
    
    /// 삭제 툴 바 버튼
    let removeToolBarButton = ToolBarButton(.remove)
    
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

extension ExcludeRecordView {
    
    enum Action {
        case setTotalImageCountLabel(Int)
        case toggleSelectMode(Bool)
        case updateSelectedCountLabel(Int)
        case toggleLoading(Bool)
    }
    
    func action(_ action: Action) {
        switch action {
        case let .setTotalImageCountLabel(count):
            totalCountLabel.text = count > 0 ? "총 \(count)장" : ""
            totalCountLabel.flex.markDirty()
            emptyLabel.isHidden = count > 0
            
        case let .toggleSelectMode(bool):
            recordCollectionView.allowsSelection = bool
            recordCollectionView.allowsMultipleSelection = bool
            [selectButton].forEach { $0.isHidden = bool }
            [selectCancelButton, toolBar].forEach { $0.isHidden = !bool }
            UIView.animate(withDuration: 0.2) { [weak self] in
                self?.recordCollectionView.contentInset.bottom = bool ? 80 : 0
            }
            
        case let .updateSelectedCountLabel(count):
            if count == 0 {
                toolBar.action(.updateTitle("기록을 선택해주세요"))
                [favoriteToolBarButton, recoverToolBarButton, seemoreToolBarButton, removeToolBarButton].forEach {
                    $0.action(.toggleDisabled(true))
                }
            } else {
                let attributedText = NSMutableAttributedString()
                    .tint("\(count)장", color: .brandPrimary)
                    .tint("의 기록이 선택됨", color: .mainLabel)
                
                toolBar.action(.updateTitle(AttributedString(attributedText)))
                [favoriteToolBarButton, recoverToolBarButton, seemoreToolBarButton, removeToolBarButton].forEach {
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

extension ExcludeRecordView {
    
    func configLayout() {
        containerView.flex.direction(.column).define { flex in
            flex.addItem(navigationBar)
            
            flex.addItem().direction(.row).justifyContent(.spaceBetween).paddingHorizontal(20).marginTop(18).define { flex in
                flex.addItem(infoLabel)
                flex.addItem(totalCountLabel)
            }
            
            flex.addItem().grow(1).marginTop(16).define { flex in
                flex.addItem(recordCollectionView).position(.absolute).all(0)
            }
            
            flex.addItem(emptyLabel).position(.absolute).alignSelf(.center).top(45%)
            flex.addItem(toolBar).position(.absolute).horizontally(0).bottom(0)
        }
        
        navigationTrailingButtons.flex.direction(.row).define { flex in
            flex.addItem(selectButton)
            flex.addItem(selectCancelButton).position(.absolute).right(0)
        }
    }
}
