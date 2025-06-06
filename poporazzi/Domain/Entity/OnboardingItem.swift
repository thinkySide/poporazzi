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
                title: .init()
                    .tint("앨범 정리, ", color: .mainLabel)
                    .tint("3단계", color: .brandPrimary)
                    .tint("로\n", color: .mainLabel)
                    .tint("쉽고 편하게 정리해요", color: .mainLabel),
                image: .first
            ),
            .init(
                title: .init()
                    .tint("I. ", color: .brandPrimary)
                    .tint("기록하고 싶은\n순간을 시작하고", color: .mainLabel),
                image: .second
            ),
            .init(
                title: .init()
                    .tint("II. ", color: .brandPrimary)
                    .tint("마음껏 즐기러\n떠나보세요!", color: .mainLabel),
                image: .third
            ),
            .init(
                title: .init()
                    .tint("III. ", color: .brandPrimary)
                    .tint("종료하면 앨범으로\n쏙 넣어드릴게요", color: .mainLabel),
                image: .fourth
            )
        ]
    }
}
