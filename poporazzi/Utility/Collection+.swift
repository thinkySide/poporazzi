//
//  Collection+.swift
//  poporazzi
//
//  Created by 김민준 on 5/27/25.
//

import Foundation

extension Collection {
    
    /// 안전한 서브스크립트 문법을 지원합니다.
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
