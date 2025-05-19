//
//  PhotoKitInterface.swift
//  poporazzi
//
//  Created by 김민준 on 5/7/25.
//

import Foundation
import RxSwift
import RxCocoa

protocol PhotoKitInterface {
    
    /// PhotoLibrary에 변화가 감지될 때 전송되는 이벤트
    var photoLibraryChange: Signal<Void> { get }
    
    /// PhotoLibrary 사용 권한을 요청합니다.
    func requestAuth()
    
    /// Thumbnail 없이 Media 배열을 반환합니다.
    func fetchMediaListWithNoThumbnail(from album: Album) -> [Media]
    
    /// Media 배열 이벤트를 반환합니다.
    func fetchMedias(from assetIdentifiers: [String]) -> Observable<[Media]>
    
    /// 즐겨찾기 상태를 전환합니다.
    func toggleFavorite(from assetIdentifiers: [String], isFavorite: Bool)
    
    /// 하나의 앨범으로 만들어 저장합니다.
    func saveAlbumAsSingle(title: String, sectionMediaList: SectionMediaList) -> Observable<Void>
    
    /// 일차별로 앨범을 나눈 후 폴더를 만들어 저장합니다.
    func saveAlubmByDay(title: String, sectionMediaList: SectionMediaList) -> Observable<Void>
    
    /// 사진을 삭제 후 결과 이벤트를 반환합니다.
    func deletePhotos(from assetIdentifiers: [String]) -> Observable<Bool>
}
