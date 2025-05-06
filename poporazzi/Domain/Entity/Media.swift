//
//  Media.swift
//  poporazzi
//
//  Created by 김민준 on 4/7/25.
//

import UIKit

/// 미디어
struct Media: Hashable {
    var id: String
    var mediaType: MediaType
    var thumbnail: UIImage
}

/// 미디어 타입
enum MediaType: Hashable {
    case photo
    case video(duration: TimeInterval)
}
