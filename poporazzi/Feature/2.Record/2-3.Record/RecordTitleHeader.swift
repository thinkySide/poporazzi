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
    
    private let messageBox = MessageBox()
    
    /// 앨범 제목 라벨
    private let albumTitleLabel = UILabel("제목", size: 24, color: .mainLabel)
    
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
        case updateTotalImageCountLabel(Int)
    }
    
    func action(_ action: Action) {
        switch action {
        case let .updateAlbumTitleLabel(text):
            albumTitleLabel.text = text
            albumTitleLabel.flex.markDirty()
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
        containerView.flex.direction(.column).backgroundColor(.white)
            .paddingHorizontal(4)
            .define { flex in
                flex.addItem(messageBox)
                flex.addItem(albumTitleLabel).marginTop(16)
                flex.addItem(totalRecordCountLabel).marginTop(4).marginLeft(2)
            }
    }
}
