//
//  CodeBaseUI+.swift
//  poporazzi
//
//  Created by 김민준 on 4/4/25.
//

import UIKit

/// Code Base UI 프로토콜을 편리하게 사용하기 위한 별칭
typealias CodeBaseUI = UIView & CodeBaseUIProtocol

/// Code Base UI 구현 시 필요한 필수 구현 프로토콜
protocol CodeBaseUIProtocol: UIView {
    
    /// FlexLayout을 위한 Container View
    var containerView: UIView { get }
    
    /// 화면 세팅
    func setup(color: UIColor)
    
    /// 레이아웃 구성
    func configLayout()
}

// MARK: - CodeBaseUIViewProtocol 기본 구현

extension CodeBaseUIProtocol {
    
    func setup(color: UIColor = .white) {
        addSubview(containerView)
        configLayout()
        backgroundColor = color
        containerView.backgroundColor = color
    }
}
