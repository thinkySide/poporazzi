//
//  Record.swift
//  poporazzi
//
//  Created by 김민준 on 4/9/25.
//

import UIKit

/// 기록
struct Record: Hashable, Equatable {
    
    /// 고유 아이디
    let id: String
    
    /// 기록 제목
    var title: String
    
    /// 시작 날짜
    var startDate: Date
    
    /// 종료 날짜
    var endDate: Date?
    
    /// 썸네일
    var thumbnail: UIImage?
    
    /// 앨범 타입
    var albumType: AlbumType
    
    /// 추정 개수
    ///
    /// - 앨범의 경우 전체 에셋 개수
    /// - 폴더의 경우 전체 앨범 개수
    var estimateCount: Int
    
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
        thumbnail: UIImage? = nil,
        albumType: AlbumType,
        estimateCount: Int = 0,
        excludeMediaList: Set<String> = [],
        mediaFetchOption: MediaFetchOption,
        mediaFilterOption: MediaFilterOption
    ) {
        self.id = id
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.thumbnail = thumbnail
        self.albumType = albumType
        self.estimateCount = estimateCount
        self.excludeMediaList = excludeMediaList
        self.mediaFetchOption = mediaFetchOption
        self.mediaFilterOption = mediaFilterOption
    }
    
    static var initialValue: Self {
        Record(
            title: "",
            startDate: .now,
            albumType: .album,
            excludeMediaList: [],
            mediaFetchOption: .all,
            mediaFilterOption: .init()
        )
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Record, rhs: Record) -> Bool {
        lhs.id == rhs.id
    }
}

/// 앨범 타입
enum AlbumType {
    
    /// 생성중
    case creating
    
    /// 앨범
    case album
    
    /// 폴더
    case folder
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
