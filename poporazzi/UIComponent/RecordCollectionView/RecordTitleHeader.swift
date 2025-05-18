//
//  RecordTitleHeader.swift
//  poporazzi
//
//  Created by 김민준 on 5/10/25.
//

import UIKit
import PinLayout
import FlexLayout

final class RecordTitleHeader: UICollectionReusableView {
    
    static let identifier = "RecordTitleHeader"
    
    var containerView = UIView()

    /// 앨범 제목 라벨
    private let albumTitleLabel = UILabel("제목", size: 24, color: .mainLabel)
    
    /// 시작 날짜 라벨
    private let startDateLabel = UILabel("날짜", size: 16, color: .subLabel)
    
    /// 총 기록 개수 라벨
    private let totalRecordCountLabel = UILabel("개수", size: 16, color: .subLabel)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(containerView)
        configLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.pin.all()
        containerView.flex.layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Action

extension RecordTitleHeader {
    
    enum Action {
        case updateAlbumTitleLabel(String)
        case updateStartDateLabel(String)
        case updateTotalImageCountLabel(Int)
    }
    
    func action(_ action: Action) {
        switch action {
        case let .updateAlbumTitleLabel(text):
            albumTitleLabel.text = text
            albumTitleLabel.flex.markDirty()
            containerView.flex.layout()
            
        case let .updateStartDateLabel(text):
            startDateLabel.text = text
            startDateLabel.flex.markDirty()
            containerView.flex.layout()
            
        case let .updateTotalImageCountLabel(count):
            totalRecordCountLabel.text = count > 0 ? "총 \(count)장" : ""
            totalRecordCountLabel.flex.markDirty()
            containerView.flex.layout()
        }
    }
}

// MARK: - Layout

extension RecordTitleHeader {
    
    func configLayout() {
        containerView.flex.direction(.column).backgroundColor(.white).paddingHorizontal(4).define { flex in
            flex.addItem(albumTitleLabel)
            
            flex.addItem().direction(.row).marginTop(6).define { flex in
                flex.addItem(startDateLabel)
                flex.addItem().grow(1)
                flex.addItem(totalRecordCountLabel)
            }
        }
    }
}
