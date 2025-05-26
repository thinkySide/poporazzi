//
//  PersistenceService.swift
//  poporazzi
//
//  Created by 김민준 on 5/13/25.
//

import Foundation
import RealmSwift

final class PersistenceService: PersistenceInterface {
    
    private let realm = try? Realm()
}

// MARK: - Album

extension PersistenceService {
    
    /// 영구 저장 앨범을 생성합니다.
    func createAlbum(from album: Album) throws {
        let album = PersistenceAlbum(
            id: album.id,
            title: album.title,
            startDate: album.startDate,
            endDate: album.endDate,
            excludeMediaList: .init(),
            mediaFetchOption: toPersistence(from: album.mediaFetchOption),
            mediaFilterOption: toPersistence(from: album.mediaFilterOption)
        )
        
        try realm?.write {
            realm?.add(album)
        }
    }
    
    /// ID를 기반으로 앨범을 반환합니다.
    func readAlbum(fromId: String) -> Album {
        if let persistenceAlbum = readPersistenceAlbum(fromId: fromId) {
            return toEntity(from: persistenceAlbum)
        } else {
            return .initialValue
        }
    }
    
    /// 앨범을 업데이트합니다.
    func updateAlbum(to newAlbum: Album) {
        guard let persistenceAlbum = readPersistenceAlbum(fromId: newAlbum.id) else { return }
        do {
            try realm?.write {
                persistenceAlbum.title = newAlbum.title
                persistenceAlbum.startDate = newAlbum.startDate
                persistenceAlbum.endDate = newAlbum.endDate
                persistenceAlbum.mediaFetchOption = toPersistence(from: newAlbum.mediaFetchOption)
                persistenceAlbum.mediaFilterOption = toPersistence(from: newAlbum.mediaFilterOption)
            }
            print("업데이트 완료")
        } catch {
            print("앨범 업데이트 실패: \(error)")
        }
    }
    
    /// 제외할 미디어 목록을 업데이트합니다.
    func updateAlbumExcludeMediaList(to album: Album) {
        guard let persistenceAlbum = readPersistenceAlbum(fromId: album.id) else {
            print("\(#function): 영구 저장 앨범 찾기 실패")
            return
        }
        
        do {
            try realm?.write {
                persistenceAlbum.excludeMediaList.removeAll()
                persistenceAlbum.excludeMediaList.append(objectsIn: Array(album.excludeMediaList))
            }
        } catch {
            print("복원할 미디어 목록 업데이트 실패: \(error)")
        }
    }
}

// MARK: - Helper

extension PersistenceService {
    
    private func readPersistenceAlbum(fromId: String) -> PersistenceAlbum? {
        let albums = realm?.objects(PersistenceAlbum.self)
        return albums?.filter({ $0.id == fromId }).first
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
            endDate: album.endDate,
            albumType: .creating,
            excludeMediaList: Set(album.excludeMediaList),
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
