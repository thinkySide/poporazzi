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
    
    /// NavigationBar
    private lazy var navigationBar = NavigationBar(
        leading: recordIcon,
        trailing: navigationTrailingButtons
    )
    
    private let recordIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .recordText
        return imageView
    }()
    
    /// 오른쪽 버튼들
    private let navigationTrailingButtons: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    /// 더보기 버튼
    let seemoreButton = NavigationButton(buttonType: .seemore, variation: .tertiary)
    
    /// 선택 버튼
    let selectButton = NavigationButton(buttonType: .text("선택"), variation: .tertiary)
    
    /// 기록 종료 버튼
    let finishRecordButton = NavigationButton(buttonType: .text("기록 종료"), variation: .primary)
    
    /// 선택 취소 버튼
    let selectCancelButton: NavigationButton = {
        let button = NavigationButton(buttonType: .text("취소"), variation: .tertiary)
        button.isHidden = true
        return button
    }()
    
    private let headerView = UIView()
    
    let titleLabel = UILabel(size: 24, color: .mainLabel)
    
    let dateLabel = UILabel(size: 16, color: .subLabel)
    
    let totalCountLabel = UILabel(size: 16, color: .subLabel)
    
    private let emptyView = UIView()
    
    let emptyFirstLabel = UILabel("📸  지금부터 촬영한 모든 기록을 저장할게요", size: 16, color: .subLabel)
    
    let emptySecondLabel = UILabel("👋  앨범 정리는 포포라치에게 맡기고 다녀오세요!", size: 16, color: .subLabel)
    
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
    
    /// 앱 아이콘
    private let appIconImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(resource: .appIcon))
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    /// 미디어 컬렉션 뷰
    let recordCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: .init())
        collectionView.backgroundColor = .white
        collectionView.clipsToBounds = true
        return collectionView
    }()
    
    init() {
        super.init(frame: .zero)
        setup(color: .brandTertiary)
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
        case updateRecordInfo(Record)
        case updateTotalCountLabel(Int)
        case toggleSelectMode(Bool)
        case toggleFavoriteMode(Bool)
        case updateSelectedCountLabel(Int)
        case toggleLoading(Bool)
    }
    
    func action(_ action: Action) {
        defer { containerView.flex.layout() }
        switch action {
        case let .updateRecordInfo(record):
            titleLabel.text = record.title
            dateLabel.text = record.startDate.startDateFormat
            [titleLabel, dateLabel].forEach { $0.flex.markDirty() }
            containerView.flex.layout()
            
        case let .updateTotalCountLabel(count):
            totalCountLabel.text = count == 0 ? "" : "총 \(count)장"
            emptyView.isHidden = count > 0
            totalCountLabel.flex.markDirty()
            containerView.flex.layout()
            
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
            
            flex.addItem(titleLabel)
                .marginHorizontal(20)
                .marginTop(0)
            
            flex.addItem(headerView)
                .paddingHorizontal(20)
                .marginTop(6)
            
            flex.addItem().grow(1).marginTop(16).define { flex in
                flex.addItem(recordCollectionView).position(.absolute).all(0).cornerRadius(32)
            }
            
            flex.addItem(emptyView)
                .position(.absolute)
                .alignSelf(.center)
                .top(45%)
            
            flex.addItem(toolBar).position(.absolute).horizontally(0).bottom(0)
        }
        
        navigationTrailingButtons.flex.direction(.row).define { flex in
            flex.addItem(seemoreButton)
            flex.addItem(selectButton).marginLeft(8)
            flex.addItem(finishRecordButton).marginLeft(8)
            flex.addItem(selectCancelButton).position(.absolute).right(0)
        }
        
        headerView.flex.direction(.row).define { flex in
            flex.addItem(dateLabel).marginLeft(2)
            flex.addItem().grow(1)
            flex.addItem(totalCountLabel)
        }
        
        emptyView.flex.direction(.column).alignItems(.center).define { flex in
            flex.addItem(emptyFirstLabel)
            flex.addItem(emptySecondLabel).marginTop(20)
        }
    }
}
