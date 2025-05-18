//
//  MediaFetchOption.swift
//  poporazzi
//
//  Created by 김민준 on 5/15/25.
//

import Foundation

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
