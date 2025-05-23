//
//  Album.swift
//  poporazzi
//
//  Created by 김민준 on 4/9/25.
//

import Foundation

/// 앨범
struct Album: Hashable, Equatable {
    
    /// 고유 아이디
    let id: String
    
    /// 앨범 제목
    var title: String
    
    /// 시작 날짜
    var startDate: Date
    
    /// 종료 날짜
    var endDate: Date?
    
    /// 제외된 미디어 리스트
    var excludeMediaList: Set<String>
    
    /// 미디어 요청 옵션
    var mediaFetchOption: MediaFetchOption
    
    /// 미디어 필터링 옵션
    var mediaFilterOption: MediaFilterOption
    
    init(
        id: String = UUID().uuidString,
        title: String,
        startDate: Date = .now,
        endDate: Date? = nil,
        excludeMediaList: Set<String> = [],
        mediaFetchOption: MediaFetchOption,
        mediaFilterOption: MediaFilterOption
    ) {
        self.id = id
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.excludeMediaList = excludeMediaList
        self.mediaFetchOption = mediaFetchOption
        self.mediaFilterOption = mediaFilterOption
    }
    
    static var initialValue: Self {
        Album(
            title: "",
            startDate: .now,
            excludeMediaList: [],
            mediaFetchOption: .all,
            mediaFilterOption: .init()
        )
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Album, rhs: Album) -> Bool {
        lhs.id == rhs.id
    }
}

/// 앨범 저장 옵션
enum AlbumSaveOption {
    
    /// 하나로 저장
    case saveAsSingle
    
    /// 일차별 저장
    case saveByDay
    
    /// 저장 없이 종료
    case noSave
}
