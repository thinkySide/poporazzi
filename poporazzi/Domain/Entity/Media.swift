//
//  Media.swift
//  poporazzi
//
//  Created by 김민준 on 4/7/25.
//

import UIKit

/// 미디어
struct Media: Hashable, Equatable {
    
    /// 고유 ID
    ///
    /// - Asset의 ID 저장
    let id: String
    
    /// 생성일
    let creationDate: Date?
    
    /// 미디어 타입
    let mediaType: MediaType
    
    /// 썸네일
    var thumbnail: UIImage?
    
    /// 즐겨찾기 여부
    var isFavorite: Bool
    
    /// 미디어 타입
    enum MediaType: Hashable {
        
        /// 사진
        case photo(PhotoType, PhotoFormat)
        
        /// 비디오
        case video(VideoType, VideoFormat, duration: TimeInterval)
        
        /// 사진 타입
        enum PhotoType {
            case selfShooting
            case download
            case screenshot
        }
        
        /// 사진 확장자
        enum PhotoFormat: String {
            case heic
            case png
            case jpeg
        }
        
        /// 비디오 타입
        enum VideoType {
            case selfShooting
            case download
        }
        
        /// 비디오 확장자
        enum VideoFormat: String {
            case quickTimeMovie = "quicktime-movie"
            case mpeg4 = "mpeg-4"
        }
    }
}

/// 미디어 검색 타입
enum MediaFetchOption {
    
    /// 전체 검색
    case all
    
    /// 사진 검색
    case photo
    
    /// 비디오 검색
    case video
    
    /// 각 검색 타입 별 제목
    var title: String {
        switch self {
        case .all: "사진 및 동영상"
        case .photo: "사진"
        case .video: "동영상"
        }
    }
}

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
    
    /// 기본값
    static var initialValue: MediaFilterOption {
        .init(
            isContainSelfShooting: true,
            isContainDownload: true,
            isContainScreenshot: true
        )
    }
}

/// 미디어 요청 시 품질 옵션
enum MediaQualityOption {
    
    /// 보통 옵션
    case normal
    
    /// 높은 옵션
    case high
}


// MARK: - Hashable & Equatable

extension Media {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Media, rhs: Media) -> Bool {
        lhs.id == rhs.id
        && lhs.thumbnail != rhs.thumbnail
    }
}

// MARK: - Helper

extension Media {
    
    /// 기본 생성 값
    static var initialValue: Media {
        .init(
            id: "",
            creationDate: nil,
            mediaType: .photo(.selfShooting, .jpeg),
            thumbnail: nil,
            isFavorite: false
        )
    }
    
    /// Media 생성일이 시작 날짜를 기준으로 몇일차인지 반환합니다.
    func daysSince(startDate: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents(
            [.day],
            from: calendar.startOfDay(for: startDate),
            to: calendar.startOfDay(for: creationDate ?? .now)
        )
        return (components.day ?? 0) + 1
    }
}

extension [Media] {
    
    /// 날짜순으로 정렬 후 반환합니다.
    var sortedByCreationDate: [Media] {
        sorted { $0.creationDate ?? Date() < $1.creationDate ?? Date() }
    }
    
    /// 날짜별로 MediaList를 분리해 반환합니다.
    func toSectionMediaList(startDate: Date) -> SectionMediaList {
        var dic = [MediaSection: [Media]]()
        
        for media in self.sortedByCreationDate {
            guard let creationDate = media.creationDate else { continue }
            let days = media.daysSince(startDate: startDate)
            dic[.day(
                order: days,
                date: Calendar.current.startOfDay(for: creationDate)
            ), default: []].append(media)
        }
        
        return dic.keys
            .sorted(by: <)
            .map { ($0, dic[$0] ?? []) }
    }
    
    /// 미디어 리스트의 값을 비교 후 즐겨찾기 값을 결정합니다.
    var shouldBeFavorite: Bool {
        let isFavoriteSet = Set(self.map(\.isFavorite))
        if isFavoriteSet.count > 1 {
            return isFavoriteSet.contains(true)
        } else {
            return !(isFavoriteSet.first ?? false)
        }
    }
}
