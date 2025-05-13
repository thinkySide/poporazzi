//
//  Album.swift
//  poporazzi
//
//  Created by 김민준 on 4/9/25.
//

import Foundation

struct Album {
    
    /// 고유 아이디
    let id: String
    
    /// 앨범 제목
    var title: String
    
    /// 시작 날짜
    var startDate: Date
    
    /// 제외된 미디어 리스트
    var excludeMediaList: [String]
    
    /// 미디어 요청 옵션
    var mediaFetchOption: MediaFetchOption
    
    /// 미디어 필터링 옵션
    var mediaFilterOption: MediaFilterOption
    
    init(
        id: String = UUID().uuidString,
        title: String,
        startDate: Date = .now,
        excludeMediaList: [String] = [],
        mediaFetchOption: MediaFetchOption,
        mediaFilterOption: MediaFilterOption
    ) {
        self.id = id
        self.title = title
        self.startDate = startDate
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
}

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

/// 앨범 저장 옵션
enum AlbumSaveOption {
    
    /// 하나로 저장
    case saveAsSingle
    
    /// 일차별 저장
    case saveByDay
    
    /// 저장 없이 종료
    case noSave
}
