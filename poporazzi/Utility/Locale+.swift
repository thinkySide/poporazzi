//
//  Locale+.swift
//  poporazzi
//
//  Created by 김민준 on 6/29/25.
//

import Foundation

extension Locale {
    
    /// 선호하는 언어에 따른 Locale 값을 반환합니다.
    ///
    /// - 기본값: en_KR
    static var preferredLanguage: Self {
        Locale(identifier: Locale.preferredLanguages.first ?? "en_KR")
    }
}
