//
//  Media.swift
//  poporazzi
//
//  Created by 김민준 on 4/7/25.
//

import UIKit

/// 미디어
struct Media: Hashable, Equatable {
    
    let id: String
    let creationDate: Date?
    let mediaType: MediaType
    var thumbnail: UIImage?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Media, rhs: Media) -> Bool {
        lhs.id == rhs.id
        && lhs.mediaType == rhs.mediaType
        && lhs.thumbnail != rhs.thumbnail
    }
}

/// 미디어 타입
enum MediaType: Hashable {
    case photo(PhotoType, PhotoFormat)
    case video(VideoType, VideoFormat, duration: TimeInterval)
}

enum PhotoType {
    case selfShooting
    case download
    case screenshot
}

enum PhotoFormat: String {
    case heic
    case png
    case jpeg
}

enum VideoType {
    case selfShooting
    case download
}

enum VideoFormat: String {
    case quickTimeMovie = "quicktime-movie"
    case mpeg4 = "mpeg-4"
}

/// 미디어 검색 타입
enum MediaFetchOption {
    case all
    case photo
    case video
}

// MARK: - Helper

extension [Media] {
    
    /// 날짜순으로 정렬 후 반환합니다.
    var sortedByCreationDate: [Media] {
        sorted { $0.creationDate ?? Date() < $1.creationDate ?? Date() }
    }
}
