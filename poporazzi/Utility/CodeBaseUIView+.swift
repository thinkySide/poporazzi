//
//  CodeBaseUIView.swift
//  poporazzi
//
//  Created by 김민준 on 4/4/25.
//

import UIKit

/// Code Base UIView 프로토콜을 편리하게 사용하기 위한 별칭
typealias CodeBaseUIView = UIView & CodeBaseUIViewProtocol

/// Code Base UIView 구현 시 필요한 필수 구현 프로토콜
protocol CodeBaseUIViewProtocol: UIView {
    
    associatedtype Action
    
    /// FlexLayout을 위한 Container View
    var containerView: UIView { get }
    
    /// 화면 세팅
    func setup()
    
    /// 레이아웃 구성
    func configLayout()
    
    /// 화면에서 실행 가능한 액션
    func action(_ action: Action)
}

// MARK: - CodeBaseUIViewProtocol 기본 구현

extension CodeBaseUIViewProtocol {
    
    func setup() {
        backgroundColor = .white
        containerView.backgroundColor = .white
        addSubview(containerView)
        configLayout()
    }
}

// MARK: - UIView 기본 구현

extension UIView {
    
    /// Code Base UIView 구현 시 필수 구현 생성자
    convenience init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
