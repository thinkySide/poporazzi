//
//  DetailView.swift
//  poporazzi
//
//  Created by 김민준 on 5/26/25.
//

import UIKit
import PinLayout
import FlexLayout

final class DetailView: CodeBaseUI {
    
    var containerView = UIView()
    
    /// NavigationBar
    private lazy var navigationBar = NavigationBar(leading: backButton)
    
    /// 뒤로가기 버튼
    let backButton = NavigationButton(buttonType: .back)
    
    let mediaView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let toolBarView = UIView()
    
    let centerToolBarView = UIView()
    
    /// 즐겨찾기 툴 바 버튼
    let favoriteToolBarButton = ToolBarButton(.favorite)
    
    /// 앨범에서 제외 툴 바 버튼
    let excludeToolBarButton = ToolBarButton(.title("앨범에서 제외"))
    
    /// 더보기 툴 바 버튼
    let seemoreToolBarButton = ToolBarButton(.seemore)
    
    /// 삭제 툴 바 버튼
    let removeToolBarButton = ToolBarButton(.remove)
    
    init() {
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.pin.top(pin.safeArea).horizontally(pin.safeArea).bottom()
        containerView.flex.layout()
    }
}

// MARK: - Action

extension DetailView {
    
    enum Action {
        
    }
    
    func action(_ action: Action) {
        switch action {
            
        }
    }
}

// MARK: - Layout

extension DetailView {
    
    func configLayout() {
        containerView.flex.direction(.column).define { flex in
            flex.addItem(navigationBar)
            
            flex.addItem(mediaView)
                .grow(1)
            
            flex.addItem(toolBarView)
                .paddingHorizontal(16)
                .height(72)
        }
        
        toolBarView.flex.direction(.row).justifyContent(.spaceBetween).define { flex in
            flex.addItem(favoriteToolBarButton)
            flex.addItem(centerToolBarView)
            flex.addItem(removeToolBarButton)
        }
        
        centerToolBarView.flex.direction(.row).define { flex in
            flex.addItem(excludeToolBarButton)
            flex.addItem(seemoreToolBarButton).marginLeft(8)
        }
    }
}
