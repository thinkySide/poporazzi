//
//  PersistenceAlbum.swift
//  poporazzi
//
//  Created by 김민준 on 5/13/25.
//

import Foundation
import RealmSwift

/// 영구 저장 앨범
final class PersistenceAlbum: Object {
    
    /// 고유 ID
    @Persisted(primaryKey: true) var id: String
    
    /// 앨범 제목
    @Persisted var title: String
    
    /// 시작 날짜
    @Persisted var startDate: Date
    
    /// 제외된 미디어 리스트
    @Persisted var excludeMediaList: List<String>
    
    /// 미디어 요청 옵션
    @Persisted var mediaFetchOption: PersistenceMediaFetchOption
    
    /// 미디어 필터링 옵션
    @Persisted var mediaFilterOption: PersistenceMediaFilterOption?
    
    convenience init(
        id: String,
        title: String,
        startDate: Date,
        excludeMediaList: List<String>,
        mediaFetchOption: PersistenceMediaFetchOption,
        mediaFilterOption: PersistenceMediaFilterOption?
    ) {
        self.init()
        self.id = id
        self.title = title
        self.startDate = startDate
        self.excludeMediaList = excludeMediaList
        self.mediaFetchOption = mediaFetchOption
        self.mediaFilterOption = mediaFilterOption
    }
}
