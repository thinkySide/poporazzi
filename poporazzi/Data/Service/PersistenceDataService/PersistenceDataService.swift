//
//  PersistenceDataService.swift
//  poporazzi
//
//  Created by 김민준 on 5/13/25.
//

import Foundation
import RealmSwift

/// 영구 저장 앨범
final class PersistenceAlbum: Object {
    
    /// 고유 ID
    @Persisted(primaryKey: true) var id: ObjectId
    
    /// 앨범 제목
    @Persisted var title: String
    
    /// 시작 날짜
    @Persisted var startDate: Date
    
    /// 제외된 미디어 리스트
    @Persisted var excludeMediaList: List<String>
    
    /// 미디어 요청 옵션
    @Persisted var mediaFetchOption: PersistenceMediaFetchOption
    
    /// 미디어 필터링 옵션
    @Persisted var mediaFilterOption: PersistenceMediaFilterOption
}

/// 영구 저장 미디어 요청 옵션
enum PersistenceMediaFetchOption: String, PersistableEnum {
    case all
    case photo
    case video
}

/// 영구 저장 미디어 필터 옵션
final class PersistenceMediaFilterOption: Object {
    
    /// 직접 촬영한 사진 포함 여부
    @Persisted var isContainSelfShooting: Bool = true
    
    /// 다운로드 사진 포함 여부
    @Persisted var isContainDownload: Bool = false
    
    /// 스크린샷 포함 여부
    @Persisted var isContainScreenshot: Bool = false
}
