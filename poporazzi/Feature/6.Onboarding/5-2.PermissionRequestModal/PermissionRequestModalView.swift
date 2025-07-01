//
//  PermissionRequestModalView.swift
//  poporazzi
//
//  Created by 김민준 on 5/21/25.
//

import UIKit
import PinLayout
import FlexLayout

final class PermissionRequestModalView: CodeBaseUI {
    
    var containerView = UIView()
    
    private let mainLabel: UILabel = {
        let label = UILabel(
            String(localized: "포포라치가 기록을\n정리할 수 있게 도와주세요!"),
            size: 18,
            color: .mainLabel
        )
        label.numberOfLines = 2
        label.setLine(alignment: .center, spacing: 4)
        return label
    }()
    
    private let subLabel = UILabel(
        String(localized: "사진은 외부로 공유되지 않으며 안전하게 보호돼요"),
        size: 14,
        color: .subLabel
    )
    
    let requestAuthImage: UIImageView = {
        let imageView = UIImageView(image: UIImage(resource: .requestAuth))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let requestAuthButton = ActionButton(
        title: String(localized: "접근 권한 확인"),
        variation: .primary
    )
    
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

// MARK: - Layout

extension PermissionRequestModalView {
    
    func configLayout() {
        containerView.flex.direction(.column).paddingHorizontal(20).define { flex in
            flex.addItem(mainLabel).alignSelf(.center).marginTop(24)
            flex.addItem(subLabel).alignSelf(.center).marginTop(8)
            
            flex.addItem(requestAuthImage).marginTop(28).height(144)
            
            flex.addItem().grow(1)
            
            flex.addItem(requestAuthButton).marginBottom(16)
        }
    }
}
