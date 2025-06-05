//
//  PaginationIndicator.swift
//  poporazzi
//
//  Created by 김민준 on 6/5/25.
//

import UIKit
import PinLayout
import FlexLayout

final class PaginationIndicator: CodeBaseUI {
    
    var containerView = UIView()
    
    private let pageCount: Int
    
    init(pageCount: Int) {
        self.pageCount = pageCount
        super.init(frame: .zero)
        setup()
    }
    
    private let firstDot: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        return view
    }()
    
    private let secondDot: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        return view
    }()
    
    private let thirdDot: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        return view
    }()
    
    private let fourthDot: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        return view
    }()
    
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

extension PaginationIndicator {
    
    enum Action {
        case updateCurrentIndex(Int)
    }
    
    func action(_ action: Action) {
        switch action {
        case let .updateCurrentIndex(index):
            let dots = [firstDot, secondDot, thirdDot, fourthDot]
            for i in 0..<pageCount {
                UIView.animate(withDuration: 0.2) {
                    dots[i].backgroundColor = i == index ? .brandPrimary : .subButton
                }
            }
        }
    }
}

// MARK: - Layout

extension PaginationIndicator {
    
    func configLayout() {
        let dots = [firstDot, secondDot, thirdDot, fourthDot]
        containerView.flex.direction(.row).justifyContent(.center).define { flex in
            for index in 0..<pageCount {
                flex.addItem(dots[index])
                    .width(8).aspectRatio(1)
                    .cornerRadius(4)
                    .marginHorizontal(4)
            }
        }
    }
}
