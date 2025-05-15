//
//  PersistenceInterface.swift
//  poporazzi
//
//  Created by 김민준 on 5/13/25.
//

import Foundation

protocol PersistenceInterface {
    
    /// 영구 저장 앨범을 생성합니다.
    func createAlbum(from album: Album) throws
    
    /// ID를 기반으로 앨범을 반환합니다.
    func readAlbum(fromId: String) -> Album
    
    /// 앨범을 업데이트합니다.
    func updateAlbum(to newAlbum: Album)
    
    /// 제외할 미디어 목록을 업데이트합니다.
    func updateAlbumExcludeMediaList(to album: Album)
}
