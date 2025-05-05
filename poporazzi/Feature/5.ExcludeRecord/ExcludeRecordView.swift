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
    
    /// NavigationBar
    private lazy var navigationBar = NavigationBar(
        title: "제외된 기록",
        leading: backButton,
        trailing: navigationTrailingButtons
    )
    
    /// 오른쪽 버튼들
    private let navigationTrailingButtons = UIView()
    
    /// 뒤로 가기 버튼
    let backButton = NavigationButton(
        buttonType: .systemIcon(.dismiss, size: 12, weight: .bold),
        variation: .secondary
    )
    
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
    let infoLabel = InfoLabel(title: "종료 시 앨범에 저장되지 않는 기록이에요")
    
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
            leading: recoverButton,
            trailing: removeButton
        )
        toolBar.isHidden = true
        return toolBar
    }()
    
    /// 앨범으로 복구 버튼
    let recoverButton = ToolBarButton(title: "앨범으로 복구")
    
    /// 삭제 버튼
    let removeButton = ToolBarButton(title: "삭제")
    
    init() {
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.pin.top(pin.safeArea).left().right().bottom()
        containerView.flex.layout()
    }
}

// MARK: - Action

extension ExcludeRecordView {
    
    enum Action {
        case toggleSelectMode(Bool)
        case updateSelectedCountLabel(Int)
    }
    
    func action(_ action: Action) {
        switch action {
        case let .toggleSelectMode(bool):
            recordCollectionView.contentInset.bottom = bool ? 56 : 0
            recordCollectionView.allowsSelection = bool
            recordCollectionView.allowsMultipleSelection = bool
            [selectButton].forEach { $0.isHidden = bool }
            [selectCancelButton, toolBar].forEach { $0.isHidden = !bool }
            
        case let .updateSelectedCountLabel(count):
            if count == 0 {
                toolBar.action(.updateTitle("기록 선택"))
                [recoverButton, removeButton].forEach {
                    $0.alpha = 0.3
                    $0.isUserInteractionEnabled = false
                }
            } else {
                toolBar.action(.updateTitle("\(count)장의 기록이 선택됨"))
                [recoverButton, removeButton].forEach {
                    $0.alpha = 1
                    $0.isUserInteractionEnabled = true
                }
            }
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
