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
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Media, rhs: Media) -> Bool {
        lhs.id == rhs.id
        && lhs.mediaType == rhs.mediaType
        && lhs.thumbnail != rhs.thumbnail
    }
    
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

// MARK: - Helper

extension [Media] {
    
    /// 날짜순으로 정렬 후 반환합니다.
    var sortedByCreationDate: [Media] {
        sorted { $0.creationDate ?? Date() < $1.creationDate ?? Date() }
    }
}
