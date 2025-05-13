//
//  AlbumOptionInputView.swift
//  poporazzi
//
//  Created by 김민준 on 5/13/25.
//

import UIKit
import PinLayout
import FlexLayout

final class AlbumOptionInputView: CodeBaseUI {
    
    var containerView = UIView()
    
    /// NavigationBar
    private lazy var navigationBar = NavigationBar(leading: backButton)
    
    /// 뒤로가기 버튼
    let backButton = NavigationButton(
        buttonType: .systemIcon(
            .left,
            size: 12,
            weight: .bold
        ),
        variation: .secondary
    )
    
    /// 메인 라벨
    let mainLabel = UILabel(
        "앨범에 저장할 항목을 선택해주세요",
        size: 22,
        color: .mainLabel
    )
    
    /// 저장 항목
    private let saveItemFormLabel = FormLabel(title: "저장 항목")
    
    /// 선택 칩 뷰
    private let choiceChipView = UIView()
    
    /// 전체 선택 칩
    let allChoiceChip = FormChoiceChip("전체", variation: .selected)
    
    /// 사진 선택 칩
    let photoChoiceChip = FormChoiceChip("사진", variation: .deselected)
    
    /// 동영상 선택 칩
    let videoChoiceChip = FormChoiceChip("동영상", variation: .deselected)
    
    /// 모든 정보 수정 가능 라벨
    private let allInfoCanChangeAnytimeSubLabel: UILabel = {
        let label = UILabel(
            "모든 정보는 언제든지 수정이 가능해요",
            size: 14,
            color: .subLabel
        )
        label.textAlignment = .center
        return label
    }()
    
    /// 저장 옵션
    private let saveOptionsFormLabel = FormLabel(title: "저장 옵션 (1개 이상 선택)")
    
    /// 직접 촬영한 항목 체크박스
    let selfShootingOptionCheckBox = FormCheckBox("직접 촬영한 항목", variation: .selected)
    
    /// 다운로드한 항목 체크박스
    let downloadOptionCheckBox = FormCheckBox("다운로드한 항목", variation: .deselected)
    
    /// 스크린샷 항목 체크박스
    let screenshotOptionCheckBox = FormCheckBox("스크린샷", variation: .deselected)
    
    /// 시작 버튼
    let startButton = ActionButton(title: "기록 시작하기", variataion: .primary)
    
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

// MARK: - Action

extension AlbumOptionInputView {
    
    enum Action {
        case updateMediaFetchType(MediaFetchType)
        case updateMediaDetailFetchType([MediaDetialFetchType])
    }
    
    func action(_ action: Action) {
        switch action {
        case let .updateMediaFetchType(fetchType):
            switch fetchType {
            case .all:
                allChoiceChip.action(.updateVariation(.selected))
                photoChoiceChip.action(.updateVariation(.deselected))
                videoChoiceChip.action(.updateVariation(.deselected))
                screenshotOptionCheckBox.isHidden = false
                
            case .image:
                allChoiceChip.action(.updateVariation(.deselected))
                photoChoiceChip.action(.updateVariation(.selected))
                videoChoiceChip.action(.updateVariation(.deselected))
                screenshotOptionCheckBox.isHidden = false
                
            case .video:
                allChoiceChip.action(.updateVariation(.deselected))
                photoChoiceChip.action(.updateVariation(.deselected))
                videoChoiceChip.action(.updateVariation(.selected))
                screenshotOptionCheckBox.isHidden = true
            }
            
        case let .updateMediaDetailFetchType(details):
            for detail in MediaDetialFetchType.allCases {
                if details.contains(detail) {
                    switch detail {
                    case .selfShooting: selfShootingOptionCheckBox.action(.updateVariation(.selected))
                    case .download: downloadOptionCheckBox.action(.updateVariation(.selected))
                    case .screenshot: screenshotOptionCheckBox.action(.updateVariation(.selected))
                    }
                } else {
                    switch detail {
                    case .selfShooting: selfShootingOptionCheckBox.action(.updateVariation(.deselected))
                    case .download: downloadOptionCheckBox.action(.updateVariation(.deselected))
                    case .screenshot: screenshotOptionCheckBox.action(.updateVariation(.deselected))
                    }
                }
            }
        }
    }
}

// MARK: - Layout

extension AlbumOptionInputView {
    
    func configLayout() {
        containerView.flex
            .direction(.column)
            .define { flex in
                flex.addItem(navigationBar)
                
                flex.addItem().direction(.column).paddingHorizontal(20).define { flex in
                    flex.addItem(mainLabel).marginTop(16)
                    
                    flex.addItem(saveItemFormLabel).marginTop(40)
                    flex.addItem(choiceChipView).marginTop(16)
                    
                    flex.addItem(saveOptionsFormLabel).marginTop(40)
                    
                    flex.addItem(selfShootingOptionCheckBox).marginTop(20)
                    flex.addItem(downloadOptionCheckBox).marginTop(20)
                    flex.addItem(screenshotOptionCheckBox).marginTop(20)
                }
                
                flex.addItem().grow(1)
                
                flex.addItem().direction(.column).paddingHorizontal(20).define { flex in
                    flex.addItem(allInfoCanChangeAnytimeSubLabel).marginBottom(12)
                    flex.addItem(startButton).marginBottom(16)
                }
            }
        
        choiceChipView.flex.direction(.row).justifyContent(.spaceBetween).define { flex in
            flex.addItem(allChoiceChip).grow(1)
            flex.addItem(photoChoiceChip).grow(1).marginHorizontal(12)
            flex.addItem(videoChoiceChip).grow(1)
        }
    }
}
