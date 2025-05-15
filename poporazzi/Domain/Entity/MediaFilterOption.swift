//
//  MediaFilterOption.swift
//  poporazzi
//
//  Created by 김민준 on 5/15/25.
//

import Foundation

/// 미디어 필터링 옵션
struct MediaFilterOption {
    
    /// 직접 촬영한 사진 포함 여부
    var isContainSelfShooting: Bool
    
    /// 다운로드 사진 포함 여부
    var isContainDownload: Bool
    
    /// 스크린샷 포함 여부
    var isContainScreenshot: Bool
    
    init(
        isContainSelfShooting: Bool = true,
        isContainDownload: Bool = false,
        isContainScreenshot: Bool = false
    ) {
        self.isContainSelfShooting = isContainSelfShooting
        self.isContainDownload = isContainDownload
        self.isContainScreenshot = isContainScreenshot
    }
}
