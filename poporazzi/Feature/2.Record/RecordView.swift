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
    
    let tapGesture = UITapGestureRecognizer()
    
    /// NavigationBar
    private lazy var navigationBar = NavigationBar(
        trailing: navigationTrailingButtons
    )
    
    /// 오른쪽 버튼들
    private let navigationTrailingButtons = UIView()
    
    /// 더보기 버튼
    let seemoreButton: NavigationButton = {
        let button = NavigationButton(
            buttonType: .systemIcon(.ellipsis, size: 14, weight: .black),
            variation: .tertiary
        )
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
        label.text = "지금부터 촬영한 모든 사진과\n영상이 기록될 거에요!"
        label.numberOfLines = 3
        label.setLine(alignment: .center, spacing: 8)
        label.font = .setDovemayo(16)
        label.textColor = .mainLabel
        return label
    }()
    
    /// 기록 컬렉션 뷰
    lazy var recordCollectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: compositionalLayout
        )
        collectionView.backgroundColor = .white
        collectionView.register(
            MomentRecordCell.self,
            forCellWithReuseIdentifier: MomentRecordCell.identifier
        )
        return collectionView
    }()
    
    private let compositionalLayout: UICollectionViewCompositionalLayout = {
        
        // 1. 기본값 변수 저장
        let numberOfRows: CGFloat = 3
        let itemInset: CGFloat = 2
        
        // 2. 아이템(Cell) 설정
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalHeight(1),
            heightDimension: .fractionalHeight(1)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .init(top: 0, leading: 0, bottom: itemInset, trailing: itemInset)
        let lastItem = NSCollectionLayoutItem(layoutSize: itemSize)
        lastItem.contentInsets = .init(top: 0, leading: 0, bottom: itemInset, trailing: 0)
        
        // 3. 그룹 설정
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalWidth(1 / numberOfRows)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item, item, lastItem]
        )
        
        // 4. 섹션 설정
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        return UICollectionViewCompositionalLayout(section: section)
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
        containerView.pin.top(pin.safeArea).left().right().bottom()
        containerView.flex.layout()
    }
}

// MARK: - Action

extension RecordView {
    
    enum Action {
        case setAlbumTitleLabel(String)
        case setStartDateLabel(String)
        case setTotalImageCountLabel(Int)
        case toggleSelectMode(Bool)
    }
    
    func action(_ action: Action) {
        defer { containerView.flex.layout() }
        switch action {
        case let .setAlbumTitleLabel(title):
            albumTitleLabel.text = title
            albumTitleLabel.flex.markDirty()
            
        case let .setStartDateLabel(text):
            startDateLabel.text = text
            startDateLabel.flex.markDirty()
            
        case let .setTotalImageCountLabel(count):
            totalRecordCountLabel.text = count > 0 ? "총 \(count)장" : ""
            totalRecordCountLabel.flex.markDirty()
            let display: Flex.Display = count > 0 ? .none : .flex
            appIconImageView.flex.display(display)
            emptyLabel.flex.display(display)
            
        case let .toggleSelectMode(bool):
            if bool {
                toolBar.action(.updateTitle("기록 선택"))
                recordCollectionView.contentInset.bottom = 56
            } else {
                recordCollectionView.contentInset.bottom = 0
            }
            [seemoreButton, selectButton, finishRecordButton].forEach { $0.isHidden = bool }
            [selectCancelButton, toolBar].forEach { $0.isHidden = !bool }
        }
    }
}

// MARK: - Layout

extension RecordView {
    
    func configLayout() {
        containerView.flex.direction(.column).define { flex in
            flex.addItem(navigationBar)
            
            flex.addItem().direction(.column).paddingHorizontal(20).define { flex in
                flex.addItem(albumTitleLabel)
                
                flex.addItem().direction(.row).marginTop(10).define { flex in
                    flex.addItem(startDateLabel)
                    flex.addItem().grow(1)
                    flex.addItem(totalRecordCountLabel)
                }
            }
            
            flex.addItem().grow(1).marginTop(24).define { flex in
                flex.addItem(recordCollectionView).position(.absolute).all(0)
                
                flex.addItem().direction(.column).position(.absolute).alignSelf(.center).alignItems(.center).top(30%).define { flex in
                    flex.addItem(appIconImageView).size(CGSize(width: 56, height: 56))
                    flex.addItem(emptyLabel).marginTop(16)
                }
            }
            
            flex.addItem(toolBar).position(.absolute).horizontally(0).bottom(0)
        }
        
        navigationTrailingButtons.flex.direction(.row).define { flex in
            flex.addItem(seemoreButton)
            flex.addItem(selectButton).marginLeft(8)
            flex.addItem(finishRecordButton).marginLeft(8)
            flex.addItem(selectCancelButton).position(.absolute).right(0)
        }
    }
}
