//
//  SettingsView.swift
//  poporazzi
//
//  Created by 김민준 on 5/23/25.
//

import UIKit
import PinLayout
import FlexLayout

final class SettingsView: CodeBaseUI {
    
    var containerView = UIView()
    
    private lazy var navigationBar = NavigationBar(
        leading: titleLabel,
        trailing: versionLabel
    )
    
    private let titleLabel = UILabel("설정", size: 20, color: .mainLabel)
    private let versionLabel = UILabel(size: 14, color: .subLabel)
    
    private let serviceFormLabel = FormLabel(title: "🛎️ 서비스")
    let writeAppStoreReviviewButton = ListButton(title: "앱스토어 리뷰 작성")
    let requestFeatureAndImprovementButton = ListButton(title: "기능 요청 및 개선사항 제안")
    let shareWithFriendsButton = ListButton(title: "친구에게 공유")
    
    private let divider = UIView()
    
    private let playWithDeveloperFormLabel = FormLabel(title: "👨‍💻 개발자랑 놀기")
    let poporazziOpenChatRoomButton = ListButton(title: "포포라치 오픈채팅방")
    let instagramButton = ListButton(title: "Instagram")
    let threadButton = ListButton(title: "Thread")
    
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

extension SettingsView {
    
    enum Action {
        case updateVersionLabel(String)
    }
    
    func action(_ action: Action) {
        switch action {
        case let .updateVersionLabel(version):
            versionLabel.text = version
            versionLabel.flex.markDirty()
            containerView.flex.layout()
        }
    }
}

// MARK: - Layout

extension SettingsView {
    
    func configLayout() {
        let spacing: CGFloat = 16
        containerView.flex.direction(.column).define { flex in
            flex.addItem(navigationBar)
            
            flex.addItem().paddingHorizontal(20).marginTop(32).define { flex in
                flex.addItem(serviceFormLabel)
                flex.addItem(writeAppStoreReviviewButton).marginTop(spacing)
                flex.addItem(requestFeatureAndImprovementButton).marginTop(spacing)
                flex.addItem(shareWithFriendsButton).marginTop(spacing)
            }
            
            flex.addItem(divider).width(.infinity).height(8).backgroundColor(.brandTertiary).marginTop(24)
            
            flex.addItem().paddingHorizontal(20).marginTop(24).define { flex in
                flex.addItem(playWithDeveloperFormLabel)
                flex.addItem(poporazziOpenChatRoomButton).marginTop(spacing)
                flex.addItem(instagramButton).marginTop(spacing)
                flex.addItem(threadButton).marginTop(spacing)
            }
        }
    }
}
