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
    let backButton = NavigationButton(buttonType: .back)
    
    /// 메인 라벨
    let mainLabel = UILabel(
        "앨범에 저장할 항목을 선택해주세요",
        size: 22,
        color: .mainLabel
    )
    
    /// 미디어 유형
    private let fetchOptionFormLabel = FormLabel(title: "미디어 종류")
    
    /// 선택 칩 뷰
    private let choiceChipView = UIView()
    
    /// 전체 선택 칩
    let allFetchChoiceChip = FormChoiceChip("전체", variation: .selected)
    
    /// 사진 선택 칩
    let photoFetchChoiceChip = FormChoiceChip("사진", variation: .deselected)
    
    /// 동영상 선택 칩
    let videoFetchChoiceChip = FormChoiceChip("동영상", variation: .deselected)
    
    /// 필터 옵션
    let filterOptionsFormLabel = FormLabel(title: "분류 기준", subtitle: "1개 이상 선택")
    
    /// 직접 촬영한 항목 체크박스
    let selfShootingFilterCheckBox = FormCheckBox("직접 촬영한 항목", variation: .selected)
    
    /// 다운로드한 항목 체크박스
    let downloadFilterCheckBox = FormCheckBox("다운로드한 항목", variation: .deselected)
    
    /// 스크린샷 항목 체크박스
    let screenshotFilterCheckBox = FormCheckBox("스크린샷", variation: .deselected)
    
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
        case updateMediaFetchOption(MediaFetchOption)
        case updateMediaFilterOption(MediaFilterOption)
        case toggleStartButton(Bool)
    }
    
    func action(_ action: Action) {
        switch action {
        case let .updateMediaFetchOption(fetchType):
            switch fetchType {
            case .all:
                allFetchChoiceChip.action(.updateVariation(.selected))
                photoFetchChoiceChip.action(.updateVariation(.deselected))
                videoFetchChoiceChip.action(.updateVariation(.deselected))
                screenshotFilterCheckBox.isHidden = false
                
            case .photo:
                allFetchChoiceChip.action(.updateVariation(.deselected))
                photoFetchChoiceChip.action(.updateVariation(.selected))
                videoFetchChoiceChip.action(.updateVariation(.deselected))
                screenshotFilterCheckBox.isHidden = false
                
            case .video:
                allFetchChoiceChip.action(.updateVariation(.deselected))
                photoFetchChoiceChip.action(.updateVariation(.deselected))
                videoFetchChoiceChip.action(.updateVariation(.selected))
                screenshotFilterCheckBox.isHidden = true
            }
            
        case let .updateMediaFilterOption(details):
            self.selfShootingFilterCheckBox.action(.updateVariation(details.isContainSelfShooting ? .selected : .deselected))
            self.downloadFilterCheckBox.action(.updateVariation(details.isContainDownload ? .selected : .deselected))
            self.screenshotFilterCheckBox.action(.updateVariation(details.isContainScreenshot ? .selected : .deselected))
            
        case let .toggleStartButton(isValid):
            startButton.action(.toggleEnabled(isValid))
            let text = isValid ? "1개 이상 선택" : "⚠️ 1개 이상 선택"
            let color: UIColor = isValid ? .subLabel : .warning
            filterOptionsFormLabel.action(.updateSubLabel(text: text, color: color))
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
                    
                    flex.addItem(fetchOptionFormLabel).marginTop(40)
                    flex.addItem(choiceChipView).marginTop(16)
                    
                    flex.addItem(filterOptionsFormLabel).marginTop(40)
                    flex.addItem(selfShootingFilterCheckBox).marginTop(20)
                    flex.addItem(downloadFilterCheckBox).marginTop(16)
                    flex.addItem(screenshotFilterCheckBox).marginTop(16)
                }
                
                flex.addItem().grow(1)
                
                flex.addItem().direction(.column).paddingHorizontal(20).define { flex in
                    flex.addItem(allInfoCanChangeAnytimeSubLabel).marginBottom(12)
                    flex.addItem(startButton).marginBottom(16)
                }
            }
        
        choiceChipView.flex.direction(.row).define { flex in
            flex.addItem(allFetchChoiceChip)
            flex.addItem(photoFetchChoiceChip).marginLeft(12)
            flex.addItem(videoFetchChoiceChip).marginLeft(12)
        }
    }
}
