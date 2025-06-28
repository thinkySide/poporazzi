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
    
    private let mainLabel: UILabel = {
        let label = UILabel(size: 22, color: .mainLabel)
        label.numberOfLines = 2
        label.textAlignment = .center
        label.setLine(alignment: .center, spacing: 6)
        return label
    }()
    
    private let randomImageView = UIView()
    
    private let firstImageContainerView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let secondImageContainerView: UIView = {
        let view = UIView()
        return view
    }()
    
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
        imageView.backgroundColor = .brandSecondary
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let recordIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .recordText
        return imageView
    }()
    
    private let recordTitleLabel = UILabel(size: 22, color: .mainLabel)
    
    private let recordInfoLabel = UILabel(size: 16, color: .subLabel)
    
    let shareButton: UIButton = {
        let button = UIButton()
        button.setTitle("공유하기", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .setDovemayo(18)
        button.backgroundColor = .brandPrimary
        button.clipsToBounds = true
        return button
    }()
    
    let showAlbumButton = ActionButton(title: "앨범 보기", variation: .secondary)
    
    let backToHomeButton = ActionButton(title: "홈으로 돌아가기", variation: .secondary)
    
    init() {
        super.init(frame: .zero)
        setup()
        firstImageContainerView.addSubview(firstImageView)
        secondImageContainerView.addSubview(secondImageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.pin.all(pin.safeArea)
        containerView.flex.layout()
        
        firstImageView.pin.all()
        secondImageView.pin.all()
        
        firstImageView.layer.cornerRadius = 18
        secondImageView.layer.cornerRadius = 18
        
        UIView.animate(withDuration: 0.5, delay: 0.3, options: .curveEaseInOut) { [weak self] in
            self?.firstImageView.transform = CGAffineTransform(rotationAngle: -8 * .pi / 180)
            self?.secondImageView.transform = CGAffineTransform(rotationAngle: 15 * .pi / 180)
        }
    }
}

// MARK: - Action

extension CompleteRecordView {
    
    enum Action {
        case updateTitleLabel(Int)
        case updateRandomImageView([UIImage])
        case updateRecordInfo(Record)
    }
    
    func action(_ action: Action) {
        switch action {
        case let .updateTitleLabel(count):
            mainLabel.attributedText = NSMutableAttributedString()
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
            
        case let .updateRecordInfo(record):
            recordTitleLabel.text = record.title
            
            let startDate = record.startDate.detailFormat
            let dayCount = (Calendar.current.dateComponents(
                [.day],
                from: record.startDate,
                to: record.endDate ?? Date()
            ).day ?? 0) +  1
            
            recordInfoLabel.text = "\(startDate)부터, \(dayCount)일간 기록"
        }
    }
}

// MARK: - Layout

extension CompleteRecordView {
    
    func configLayout() {
        containerView.flex.direction(.column).define { flex in
            flex.addItem(navigationBar)
            
            flex.addItem(mainLabel).alignSelf(.center)
            
            flex.addItem(randomImageView)
                .marginTop(40)
                .height(280)
            
            flex.addItem(recordIcon).marginTop(24).alignSelf(.center)
            flex.addItem(recordTitleLabel).marginTop(8).alignSelf(.center)
            flex.addItem(recordInfoLabel).marginTop(8).alignSelf(.center)
            
            flex.addItem(shareButton)
                .paddingHorizontal(16).height(40)
                .marginTop(24).alignSelf(.center).cornerRadius(20)
            
            flex.addItem().grow(1)
            
            flex.addItem(actionbuttonView).marginBottom(16).paddingHorizontal(20)
        }
        
        randomImageView.flex.define { flex in
            flex.addItem(firstImageContainerView)
                .width(140).aspectRatio(1)
                .alignSelf(.center)
                .position(.absolute)
                .marginRight(110)
            
            flex.addItem(secondImageContainerView)
                .width(190).aspectRatio(1)
                .position(.absolute)
                .alignSelf(.center)
                .marginTop(50)
                .marginLeft(70)
        }
        
        actionbuttonView.flex.direction(.row).justifyContent(.spaceBetween).define { flex in
            flex.addItem(showAlbumButton).grow(1).maxWidth(50%)
            flex.addItem(backToHomeButton).grow(1).maxWidth(50%).marginLeft(12)
        }
    }
}
