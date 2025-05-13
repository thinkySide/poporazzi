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
            id: album.id,
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
    
    /// ID를 기반으로 앨범을 반환합니다.
    func readAlbum(fromId: String) -> Album {
        if let persistenceAlbum = readPersistenceAlbum(fromId: fromId) {
            let entity = toEntity(from: persistenceAlbum)
            print(entity)
            return entity
        } else {
            return .initialValue
        }
    }
    
    /// 앨범을 업데이트합니다.
    func updateAlbum(_ newAlbum: Album) {
        guard let persistenceAlbum = readPersistenceAlbum(fromId: newAlbum.id) else {
            print("조기 종료")
            return
        }
        do {
            try realm.write {
                persistenceAlbum.title = newAlbum.title
                persistenceAlbum.startDate = newAlbum.startDate
                // persistenceAlbum.excludeMediaList.append(objectsIn: newAlbum.excludeMediaList)
                persistenceAlbum.mediaFetchOption = toPersistence(from: newAlbum.mediaFetchOption)
                persistenceAlbum.mediaFilterOption = toPersistence(from: newAlbum.mediaFilterOption)
            }
            print("업데이트 완료")
        } catch {
            print("앨범 업데이트 실패: \(error)")
        }
    }
    
    /// 제외할 미디어 목록을 업데이트합니다.
    func appendExcludeMediaList(albumId: String, excludeList: [String]) {
        let album = readPersistenceAlbum(fromId: albumId)
        do {
            try realm.write {
                album?.excludeMediaList.append(objectsIn: excludeList)
            }
        } catch {
            print("제외할 미디어 목록 업데이트 실패: \(error)")
        }
    }
}

// MARK: - Helper

extension PersistenceService {
    
    private func readPersistenceAlbum(fromId: String) -> PersistenceAlbum? {
        let albums = realm.objects(PersistenceAlbum.self)
        return albums.filter({ $0.id == fromId }).first
    }
}

// MARK: - Converter

extension PersistenceService {
    
    private func toPersistence(from fetchOption: MediaFetchOption) -> PersistenceMediaFetchOption {
        switch fetchOption {
        case .all: .all
        case .photo: .photo
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
    
    private func toEntity(from album: PersistenceAlbum) -> Album {
        .init(
            id: album.id,
            title: album.title,
            startDate: album.startDate,
            excludeMediaList: Array(album.excludeMediaList),
            mediaFetchOption: toEntity(from: album.mediaFetchOption),
            mediaFilterOption: toEntity(from: album.mediaFilterOption)
        )
    }
    
    private func toEntity(from fetchOption: PersistenceMediaFetchOption) -> MediaFetchOption {
        switch fetchOption {
        case .all: .all
        case .photo: .photo
        case .video: .video
        }
    }
    
    private func toEntity(from filterOption: PersistenceMediaFilterOption?) -> MediaFilterOption {
        .init(
            isContainSelfShooting: filterOption?.isContainSelfShooting ?? true,
            isContainDownload: filterOption?.isContainDownload ?? true,
            isContainScreenshot: filterOption?.isContainScreenshot ?? true
        )
    }
}
