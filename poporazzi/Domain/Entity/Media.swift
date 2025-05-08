//
//  Media.swift
//  poporazzi
//
//  Created by 김민준 on 4/7/25.
//

import UIKit

/// 미디어
struct Media: Hashable, Equatable {
    var id: String
    var mediaType: MediaType
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

/// 순서 보장이 필요한 Media 튜플
typealias OrderedMedia = (Int, Media)

/// 미디어 타입
enum MediaType: Hashable {
    case photo
    case video(duration: TimeInterval)
}

/// 미디어 검색 타입
enum MediaFetchType {
    case all
    case image
    case video
}
