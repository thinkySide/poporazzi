//
//  PhotoKitInterface.swift
//  poporazzi
//
//  Created by 김민준 on 5/7/25.
//

import Foundation
import RxSwift
import RxCocoa
import Photos

protocol PhotoKitInterface {
    
    // MARK: - Observer
    
    /// PhotoLibrary에 변화가 감지될 때 전송되는 이벤트
    var photoLibraryAssetChange: Signal<Void> { get }
    
    /// PhotoLibrary에 변화가 감지될 때 전송되는 이벤트
    var photoLibraryCollectionChange: Signal<Void> { get }
    
    
    // MARK: - Permission
    
    /// PhotoLibrary 사용 권한을 확인합니다.
    func checkPermission() -> PHAuthorizationStatus
    
    /// PhotoLibrary 사용 권한을 요청합니다.
    func requestPermission() -> Observable<PHAuthorizationStatus>
    
    
    // MARK: - Album List
    
    /// 앨범 리스트를 반환합니다.
    func fetchAllAlbumList() throws -> [Album]
    
    /// 폴더로 부터 앨범 리스트를 반환합니다.
    func fetchAlbumList(from folder: Album) -> [Album]
    
    /// 썸네일과 함께 앨범 리스트를 반환합니다.
    func fetchAlbumListWithThumbnail(from albumList: [Album]) -> Observable<[Album]>
    
    
    // MARK: - Media List
    
    /// 앨범으로 미디어 리스트를 반환합니다.
    func fetchMediaList(from album: Album) -> [Media]
    
    /// 기록으로 미디어 리스트를 반환합니다.
    func fetchMediaList(from record: Record) throws -> [Media]
    
    /// 썸네일과 함께 미디어 리스트를 반환합니다.
    func fetchMediaListWithThumbnail(
        from assetIdentifiers: [String],
        option: MediaQualityOption
    ) -> Observable<[Media]>
    
    
    // MARK: - Album Remote
    
    /// 하나의 앨범으로 만들어 저장합니다.
    func saveAlbumAsSingle(
        title: String,
        sectionMediaList: SectionMediaList
    ) -> Observable<Void>
    
    /// 일차별로 앨범을 나눈 후 폴더를 만들어 저장합니다.
    func saveAlubmByDay(
        title: String,
        sectionMediaList: SectionMediaList
    ) -> Observable<Void>
    
    /// 앨범을 수정한 후 결과 이벤트를 반환합니다.
    func editAlbum(to album: Album) -> Observable<Bool>
    
    /// 앨범에서 에셋을 제외합니다.
    func excludePhotos(
        from album: Album,
        to assetIdentifiers: [String]
    ) -> Observable<Bool>
    
    /// 앨범 삭제 후 결과 이벤트를 반환합니다.
    func removeAlbum(from identifiers: [String]) -> Observable<Bool>
    
    /// 폴더 삭제 후 결과 이벤트를 반환합니다.
    func removeFolder(from identifiers: [String]) -> Observable<Bool>
    
    
    // MARK: - Media Remote
    
    /// 즐겨찾기 상태를 전환합니다.
    func toggleMediaFavorite(from assetIdentifiers: [String], isFavorite: Bool)
    
    /// 사진을 삭제 후 결과 이벤트를 반환합니다.
    func removePhotos(from assetIdentifiers: [String]) -> Observable<Bool>
    
    
    // MARK: - Share
    
    /// 선택한 AssetIdentifiers의 공유 Item을 반환합니다.
    func fetchShareItemList(from assetIdentifiers: [String]) -> Observable<[Any]>
}
