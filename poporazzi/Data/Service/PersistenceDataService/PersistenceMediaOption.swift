//
//  PersistenceMediaOption.swift
//  poporazzi
//
//  Created by 김민준 on 5/13/25.
//

import RealmSwift

/// 영구 저장 미디어 요청 옵션
enum PersistenceMediaFetchOption: String, PersistableEnum {
    case all
    case photo
    case video
}

/// 영구 저장 미디어 필터 옵션
final class PersistenceMediaFilterOption: EmbeddedObject {
    
    /// 직접 촬영한 사진 포함 여부
    @Persisted var isContainSelfShooting: Bool = true
    
    /// 다운로드 사진 포함 여부
    @Persisted var isContainDownload: Bool = false
    
    /// 스크린샷 포함 여부
    @Persisted var isContainScreenshot: Bool = false
    
    convenience init(
        isContainSelfShooting: Bool,
        isContainDownload: Bool,
        isContainScreenshot: Bool
    ) {
        self.init()
        self.isContainSelfShooting = isContainSelfShooting
        self.isContainDownload = isContainDownload
        self.isContainScreenshot = isContainScreenshot
    }
}
