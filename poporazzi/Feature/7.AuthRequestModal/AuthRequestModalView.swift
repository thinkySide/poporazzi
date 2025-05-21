//
//  AuthRequestModalView.swift
//  poporazzi
//
//  Created by 김민준 on 5/21/25.
//

import UIKit
import PinLayout
import FlexLayout

final class AuthRequestModalView: CodeBaseUI {
    
    var containerView = UIView()
    
    private let mainLabel: UILabel = {
        let label = UILabel(
            "포포라치가 기록을\n정리할 수 있게 도와주세요",
            size: 18,
            color: .mainLabel
        )
        label.numberOfLines = 2
        label.setLine(alignment: .center, spacing: 4)
        return label
    }()
    
    private let subLabel = UILabel(
        "사진 보관함 접근 권한이 필요해요",
        size: 14,
        color: .subLabel
    )
    
    let requestAuthImage: UIImageView = {
        let imageView = UIImageView(image: UIImage(resource: .requestAuth))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let requestAuthButton = ActionButton(title: "접근 권한 확인", variataion: .primary)
    
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

extension AuthRequestModalView {
    
    enum Action {
        
    }
    
    func action(_ action: Action) {
        switch action {
            
        }
    }
}

// MARK: - Layout

extension AuthRequestModalView {
    
    func configLayout() {
        containerView.flex.direction(.column).paddingHorizontal(20).define { flex in
            flex.addItem(mainLabel).alignSelf(.center).marginTop(24)
            flex.addItem(subLabel).alignSelf(.center).marginTop(8)
            
            flex.addItem(requestAuthImage).marginTop(28).height(144)
            
            flex.addItem(requestAuthButton).marginTop(32)
        }
    }
}
