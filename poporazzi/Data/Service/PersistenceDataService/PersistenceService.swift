//
//  PersistenceService.swift
//  poporazzi
//
//  Created by 김민준 on 5/13/25.
//

import Foundation
import RealmSwift

final class PersistenceService {
    
    private let realm = try! Realm()
}

// MARK: - Album

extension PersistenceService {
    
    /// 영구 저장 앨범을 생성합니다.
    func createAlbum(
        from album: Album,
        fetchOption: MediaFetchOption,
        filterOption: MediaFilterOption
    ) throws {
        let album = PersistenceAlbum(
            title: album.title,
            startDate: album.startDate,
            excludeMediaList: .init(),
            mediaFetchOption: toPersistence(from: fetchOption),
            mediaFilterOption: toPersistence(from: filterOption)
        )
        
        try realm.write {
            realm.add(album)
        }
    }
    
    /// 영구 저장 앨범을 반환합니다.
    func readAlbum() {
        let albums = realm.objects(PersistenceAlbum.self)
        let first = albums.first
        print(first?.title)
    }
}

// MARK: - Converter

extension PersistenceService {
    
    private func toPersistence(from fetchOption: MediaFetchOption) -> PersistenceMediaFetchOption {
        switch fetchOption {
        case .all: .all
        case .image: .photo
        case .video: .video
        }
    }
    
    private func toPersistence(from filterOption: MediaFilterOption) -> PersistenceMediaFilterOption {
        .init(
            isContainSelfShooting: filterOption.isContainSelfShooting,
            isContainDownload: filterOption.isContainDownload,
            isContainScreenshot: filterOption.isContainScreenshot
        )
    }
}
