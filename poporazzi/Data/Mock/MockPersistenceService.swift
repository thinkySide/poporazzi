//
//  MockPersistenceService.swift
//  poporazzi
//
//  Created by 김민준 on 5/15/25.
//

import Foundation

struct MockPersistenceService: PersistenceInterface {
    func createAlbum(from album: Record) throws {
        print("앨범 생성 완료: \(album.title), \(album.startDate.startDateFullFormat)")
    }
    
    func readAlbum(fromId: String) -> Record {
        .initialValue
    }
    
    func updateAlbum(to newAlbum: Record) {
        print("앨범 업데이트 완료: \(newAlbum.title), \(newAlbum.startDate.startDateFullFormat)")
    }
    
    func updateAlbumExcludeMediaList(to album: Record) {
        print("제외할 미디어 리스트 업데이트 완료 : \(album.excludeMediaList)")
    }
}
