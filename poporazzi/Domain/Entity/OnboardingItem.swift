//
//  OnboardingItem.swift
//  poporazzi
//
//  Created by 김민준 on 6/4/25.
//

import UIKit

/// 온보딩 아이템을 표현하는 구조체
struct OnboardingItem: Hashable {
    
    /// 제목
    let title: NSMutableAttributedString
    
    /// 이미지
    let image: UIImage
}

// MARK: - Helper

extension OnboardingItem {
    
    /// 온보딩 아이템
    static var list: [OnboardingItem] {
        [
            .init(
                title: .init().highlight(
                    text: String(localized: "앨범 정리, 3단계로\n쉽고 편하게 정리해요"),
                    highlights: [.init(text: String(localized: "3단계"), color: .brandPrimary)]
                ),
                image: .first
            ),
            .init(
                title: .init().highlight(
                    text: String(localized: "I. 기록하고 싶은\n순간을 시작하고"),
                    highlights: [.init(text: "I.", color: .brandPrimary)]
                ),
                image: .second
            ),
            .init(
                title: .init().highlight(
                    text: String(localized: "II. 마음껏 즐기러\n떠나보세요!"),
                    highlights: [.init(text: "II.", color: .brandPrimary)]
                ),
                image: .third
            ),
            .init(
                title: .init().highlight(
                    text: String(localized: "III. 종료하면 앨범으로\n쏙 넣어드릴게요"),
                    highlights: [.init(text: "III.", color: .brandPrimary)]
                ),
                image: .fourth
            )
        ]
    }
}
