//
//  MomentRecordView.swift
//  poporazzi
//
//  Created by 김민준 on 4/5/25.
//

import UIKit
import PinLayout
import FlexLayout

final class MomentRecordView: CodeBaseUIView {
    
    var containerView = UIView()
    
    /// NavigationBar
    private lazy var navigationBar = NavigationBar(
        trailing: finishRecordButton
    )
    
    /// 기록 종료 버튼
    let finishRecordButton = NavigationButton(buttonType: .text("기록 종료"))
    
    /// 앨범 제목 라벨
    private let albumTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .setPretendard(.bold, 22)
        label.textColor = .mainLabel
        return label
    }()
    
    /// 트래킹 시작 날짜 라벨
    private let trackingStartDateLabel: UILabel = {
        let label = UILabel()
        label.font = .setPretendard(.semiBold, 15)
        label.textColor = .subLabel
        return label
    }()
    
    /// 총 사진 개수 라벨
    private let totalImageCountLabel: UILabel = {
        let label = UILabel()
        label.font = .setPretendard(.semiBold, 15)
        label.textColor = .subLabel
        return label
    }()
    
    init() {
        super.init(frame: .zero)
        setup()
        action(.setAlbumTitleLabel("일본 추억 여행"))
        action(.setTrackingStartDateLabel("2025년 4월 3일 목요일 22:25 ~"))
        action(.setTotalImageCountLabel(56))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.pin.all(pin.safeArea)
        containerView.flex.layout()
    }
}

// MARK: - Action

extension MomentRecordView {
    
    enum Action {
        case setAlbumTitleLabel(String)
        case setTrackingStartDateLabel(String)
        case setTotalImageCountLabel(Int)
    }
    
    func action(_ action: Action) {
        switch action {
        case let .setAlbumTitleLabel(title):
            albumTitleLabel.text = title
            
        case let .setTrackingStartDateLabel(text):
            trackingStartDateLabel.text = text
            
        case let .setTotalImageCountLabel(count):
            totalImageCountLabel.text = "총 \(count)장"
        }
    }
}

// MARK: - Layout

extension MomentRecordView {
    
    func configLayout() {
        containerView.flex.direction(.column)
            .define { flex in
                flex.addItem(navigationBar)
                
                flex.addItem().direction(.column).paddingHorizontal(20)
                    .define { flex in
                        flex.addItem(albumTitleLabel)
                        
                        flex.addItem().direction(.row).marginTop(10).define { flex in
                            flex.addItem(trackingStartDateLabel)
                            flex.addItem().grow(1)
                            flex.addItem(totalImageCountLabel)
                        }
                    }
            }
    }
}
