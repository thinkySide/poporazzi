//
//  AlbumDetailHeader.swift
//  poporazzi
//
//  Created by 김민준 on 6/1/25.
//

import UIKit
import PinLayout
import FlexLayout

final class AlbumDetailHeader: UICollectionReusableView {
    
    static let identifier = "AlbumDetailHeader"
    
    var containerView = UIView()
    
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

extension AlbumDetailHeader {
    
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

extension AlbumDetailHeader {
    
    func configLayout() {
        containerView.flex.direction(.row).backgroundColor(.white)
            .paddingHorizontal(4)
            .define { flex in
                flex.addItem(albumTitleLabel).shrink(1)
                flex.addItem().grow(1)
                flex.addItem(totalRecordCountLabel)
            }
    }
}
