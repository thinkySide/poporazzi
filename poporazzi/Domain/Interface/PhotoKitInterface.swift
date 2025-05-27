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
    
    /// PhotoLibrary에 변화가 감지될 때 전송되는 이벤트
    var photoLibraryAssetChange: Signal<Void> { get }
    
    /// PhotoLibrary에 변화가 감지될 때 전송되는 이벤트
    var photoLibraryCollectionChange: Signal<Void> { get }
    
    /// PhotoLibrary 사용 권한을 확인합니다.
    func checkPermission() -> PHAuthorizationStatus
    
    /// PhotoLibrary 사용 권한을 요청합니다.
    func requestPermission() -> Observable<PHAuthorizationStatus>
    
    /// 썸네일 없이 앨범 리스트를 반환합니다.
    func fetchAlbumListWithNoThumbnail() throws -> [Album]
    
    /// 앨범 리스트를 반환합니다.
    func fetchAlbumList(from albumList: [Album]) -> Observable<[Album]>
    
    /// 썸네일 없이 미디어 리스트를 반환합니다.
    func fetchMediaListWithNoThumbnail(from album: Album) throws -> [Media]
    
    /// 미디어 리스트 스트림을 반환합니다.
    func fetchMedias(from assetIdentifiers: [String], option: MediaQualityOption) -> Observable<[Media]>
    
    /// 즐겨찾기 상태를 전환합니다.
    func toggleFavorite(from assetIdentifiers: [String], isFavorite: Bool)
    
    /// 하나의 앨범으로 만들어 저장합니다.
    func saveAlbumAsSingle(title: String, sectionMediaList: SectionMediaList) -> Observable<Void>
    
    /// 일차별로 앨범을 나눈 후 폴더를 만들어 저장합니다.
    func saveAlubmByDay(title: String, sectionMediaList: SectionMediaList) -> Observable<Void>
    
    /// 사진을 삭제 후 결과 이벤트를 반환합니다.
    func deletePhotos(from assetIdentifiers: [String]) -> Observable<Bool>
    
    /// 선택한 AssetIdentifiers의 공유 Item을 반환합니다.
    func fetchShareItemList(from assetIdentifiers: [String]) -> Observable<[Any]>
}
