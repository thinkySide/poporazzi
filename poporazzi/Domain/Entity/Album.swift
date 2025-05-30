//
//  Album.swift
//  poporazzi
//
//  Created by 김민준 on 5/28/25.
//

import UIKit

/// 앨범
struct Album: Hashable, Equatable {
    
    /// 고유 아이디
    let id: String
    
    /// 앨범 제목
    var title: String
    
    /// 생성일
    var creationDate: Date
    
    /// 썸네일 리스트
    ///
    /// - 앨범의 경우 1개
    /// - 폴더의 경우 최대 4개
    var thumbnailList: [UIImage?]
    
    /// 추정 개수
    ///
    /// - 앨범의 경우 전체 에셋 개수
    /// - 폴더의 경우 전체 앨범 개수
    var estimateCount: Int
    
    /// 앨범 타입
    var albumType: AlbumType
    
    /// 앨범 타입
    enum AlbumType {
        
        /// 앨범
        case album
        
        /// 폴더
        case folder
    }
}

// MARK: - Hashable & Equatable

extension Album {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Album, rhs: Album) -> Bool {
        lhs.id == rhs.id
    }
}
