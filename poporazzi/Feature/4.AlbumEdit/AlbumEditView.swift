//
//  AlbumEditView.swift
//  poporazzi
//
//  Created by 김민준 on 4/17/25.
//

import UIKit
import PinLayout
import FlexLayout

final class AlbumEditView: CodeBaseUI {
    
    var containerView = UIView()
    
    let tapGesture = UITapGestureRecognizer()
    
    /// NavigationBar
    private lazy var navigationBar = NavigationBar(
        title: "앨범 수정",
        leading: backButton,
        trailing: saveButton
    )
    
    /// 뒤로 가기 버튼
    let backButton = NavigationButton(
        buttonType: .systemIcon(.dismiss, size: 12, weight: .bold),
        variation: .secondary
    )
    
    /// 저장 버튼
    let saveButton = NavigationButton(
        buttonType: .text("저장"),
        variation: .secondary
    )
    
    /// 제목 양식 라벨
    let titleFormLabel = FormLabel(title: "앨범 이름")
    
    /// 제목 텍스트필드
    let titleTextField = LineTextField(size: 20, placeholder: "플레이스홀더")
    
    /// 시작날짜 양식 라벨
    let startDateFormLabel = FormLabel(title: "시작 날짜")
    
    /// 시작날짜 피커
    let startDatePicker = FormDatePicker()
    
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
    
    /// 저장 옵션
    private let saveOptionsFormLabel = FormLabel(title: "저장 옵션 (1개 이상 선택)")
    
    /// 직접 촬영한 항목 체크박스
    let selfShootingOptionCheckBox = FormCheckBox("직접 촬영한 항목", variation: .selected)
    
    /// 다운로드한 항목 체크박스
    let downloadOptionCheckBox = FormCheckBox("다운로드한 항목", variation: .deselected)
    
    /// 스크린샷 항목 체크박스
    let screenshotOptionCheckBox = FormCheckBox("스크린샷", variation: .deselected)
    
    init() {
        super.init(frame: .zero)
        setup()
        addGestureRecognizer(tapGesture)
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

extension AlbumEditView {
    
    enum Action {
        case updateMediaFetchOption(MediaFetchOption)
        case updateMediaFilterOption(MediaFilterOption)
    }
    
    func action(_ action: Action) {
        switch action {
        case let .updateMediaFetchOption(fetchType):
            switch fetchType {
            case .all:
                allChoiceChip.action(.updateVariation(.selected))
                photoChoiceChip.action(.updateVariation(.deselected))
                videoChoiceChip.action(.updateVariation(.deselected))
                screenshotOptionCheckBox.isHidden = false
                
            case .photo:
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
            
        case let .updateMediaFilterOption(details):
            self.selfShootingOptionCheckBox.action(.updateVariation(details.isContainSelfShooting ? .selected : .deselected))
            self.downloadOptionCheckBox.action(.updateVariation(details.isContainDownload ? .selected : .deselected))
            self.screenshotOptionCheckBox.action(.updateVariation(details.isContainScreenshot ? .selected : .deselected))
        }
    }
}

// MARK: - Layout

extension AlbumEditView {
    
    func configLayout() {
        containerView.flex.direction(.column).define { flex in
            flex.addItem(navigationBar)
            
            flex.addItem().paddingHorizontal(20).define { flex in
                flex.addItem(titleFormLabel).marginTop(24)
                flex.addItem(titleTextField).marginTop(12)
                
                flex.addItem(startDateFormLabel).marginTop(32)
                flex.addItem(startDatePicker).marginTop(12)
                
                flex.addItem(saveItemFormLabel).marginTop(40)
                flex.addItem(choiceChipView).marginTop(16)
                
                flex.addItem(saveOptionsFormLabel).marginTop(40)
                flex.addItem(selfShootingOptionCheckBox).marginTop(20)
                flex.addItem(downloadOptionCheckBox).marginTop(16)
                flex.addItem(screenshotOptionCheckBox).marginTop(16)
            }
        }
        
        choiceChipView.flex.direction(.row).justifyContent(.spaceBetween).define { flex in
            flex.addItem(allChoiceChip).grow(1)
            flex.addItem(photoChoiceChip).grow(1).marginHorizontal(12)
            flex.addItem(videoChoiceChip).grow(1)
        }
    }
}
