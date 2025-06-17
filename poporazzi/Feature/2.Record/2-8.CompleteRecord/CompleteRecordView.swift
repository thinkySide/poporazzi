//
//  CompleteRecordView.swift
//  poporazzi
//
//  Created by 김민준 on 6/17/25.
//

import UIKit
import PinLayout
import FlexLayout

final class CompleteRecordView: CodeBaseUI {
    
    var containerView = UIView()
    
    private lazy var navigationBar = NavigationBar()
    
    private let actionbuttonView = UIView()
    
    private let titleLabel: UILabel = {
        let label = UILabel(size: 22, color: .mainLabel)
        label.numberOfLines = 2
        label.textAlignment = .center
        label.setLine(alignment: .center, spacing: 6)
        return label
    }()
    
    private let randomImageView = UIView()
    
    private let firstImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .brandTertiary
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let secondImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .brandTertiary
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let showAlbumButton = ActionButton(title: "앨범 보기", variation: .secondary)
    
    let backToHomeButton = ActionButton(title: "홈으로 돌아가기", variation: .secondary)
    
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
        firstImageView.transform = CGAffineTransform(rotationAngle: -8 * .pi / 180)
        secondImageView.transform = CGAffineTransform(rotationAngle: 15 * .pi / 180)
    }
}

// MARK: - Action

extension CompleteRecordView {
    
    enum Action {
        case updateTitleLabel(Int)
        case updateRandomImageView([UIImage])
    }
    
    func action(_ action: Action) {
        switch action {
        case let .updateTitleLabel(count):
            titleLabel.attributedText = NSMutableAttributedString()
                .tint("소중한 기록 ", color: .mainLabel)
                .tint("\(count)장", color: .brandPrimary)
                .tint("을\n앨범으로 저장했어요", color: .mainLabel)
            
        case let .updateRandomImageView(imageList):
            if let firstImage = imageList[safe: 0] {
                firstImageView.image = firstImage
            }
            if let secondImage = imageList[safe: 1] {
                secondImageView.image = secondImage
            }
        }
    }
}

// MARK: - Layout

extension CompleteRecordView {
    
    func configLayout() {
        containerView.flex.direction(.column).define { flex in
            flex.addItem(navigationBar)
            
            flex.addItem(titleLabel).alignSelf(.center)
            
            flex.addItem(randomImageView)
                .marginTop(40)
            
            flex.addItem().grow(1)
            
            flex.addItem(actionbuttonView).marginBottom(16).paddingHorizontal(20)
        }
        
        randomImageView.flex.define { flex in
            flex.addItem(firstImageView)
                .width(140).aspectRatio(1).cornerRadius(18)
                .alignSelf(.center)
                .position(.absolute)
                .marginRight(110)
            
            flex.addItem(secondImageView)
                .width(190).aspectRatio(1).cornerRadius(18)
                .alignSelf(.center)
                .position(.absolute)
                .marginTop(50)
                .marginLeft(70)
        }
        
        actionbuttonView.flex.direction(.row).justifyContent(.spaceBetween).define { flex in
            flex.addItem(showAlbumButton).grow(1).maxWidth(50%)
            flex.addItem(backToHomeButton).grow(1).maxWidth(50%).marginLeft(12)
        }
    }
}
