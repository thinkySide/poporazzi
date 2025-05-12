//
//  FinishConfirmModalView.swift
//  poporazzi
//
//  Created by 김민준 on 5/11/25.
//

import UIKit
import PinLayout
import FlexLayout

final class FinishConfirmModalView: CodeBaseUI {
    
    var containerView = UIView()
    
    /// 로딩 인디케이터
    private let loadingIndicator = LoadingIndicator()
    
    /// 기록 종료 라벨
    private let finishLabel = UILabel(
        "기록을 종료할까요?",
        size: 18,
        color: .mainLabel
    )
    
    /// 하나로 저장 라디오 버튼
    let saveAsSingleRadioButton = RadioButton(
        title: "하나로 저장",
        sub: "모든 사진이 하나의 앨범으로 저장돼요",
        variation: .selected
    )
    
    /// 일차별 저장 라디오 버튼
    let saveByDayRadioButton = RadioButton(
        title: "일차별 저장",
        sub: "모든 일차별로 앨범을 생성 후 한 폴더에 저장돼요",
        variation: .deselected
    )
    
    /// 저장 없이 종료 라디오 버튼
    let noSaveRadioButton = RadioButton(
        title: "저장 없이 종료",
        sub: "앨범 저장 없이 기록이 종료돼요",
        variation: .deselected
    )
    
    /// 종료 버튼
    let finishButton = ActionButton(title: "기록 종료하기", variataion: .primary)
    
    /// 취소 버튼
    let cancelButton = CancelButton()
    
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
        containerView.pin.all(pin.safeArea)
        loadingIndicator.pin.all()
        containerView.flex.layout()
        loadingIndicator.flex.layout()
    }
}

// MARK: - Action

extension FinishConfirmModalView {
    
    enum Action {
        case updateRadioState(AlbumSaveOption)
        case toggleLoading(Bool)
    }
    
    func action(_ action: Action) {
        switch action {
        case .updateRadioState(let radioState):
            switch radioState {
            case .saveAsSingle:
                saveAsSingleRadioButton.action(.updateState(.selected))
                saveByDayRadioButton.action(.updateState(.deselected))
                noSaveRadioButton.action(.updateState(.deselected))
                
            case .saveByDay:
                saveAsSingleRadioButton.action(.updateState(.deselected))
                saveByDayRadioButton.action(.updateState(.selected))
                noSaveRadioButton.action(.updateState(.deselected))
                
            case .noSave:
                saveAsSingleRadioButton.action(.updateState(.deselected))
                saveByDayRadioButton.action(.updateState(.deselected))
                noSaveRadioButton.action(.updateState(.selected))
            }
            
        case let .toggleLoading(isActive):
            loadingIndicator.isHidden = !isActive
            loadingIndicator.action(isActive ? .start : .stop)
        }
    }
}

// MARK: - Layout

extension FinishConfirmModalView {
    
    func configLayout() {
        containerView.flex.direction(.column).paddingHorizontal(20).define { flex in
            flex.addItem(finishLabel).marginTop(28).alignSelf(.center)
            
            flex.addItem(saveAsSingleRadioButton).marginTop(24)
            flex.addItem(saveByDayRadioButton).marginTop(16)
            flex.addItem(noSaveRadioButton).marginTop(16)
            
            flex.addItem(finishButton).marginTop(32)
            flex.addItem(cancelButton).marginTop(8).alignSelf(.center)
        }
    }
}
