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
    func fetchMediasWithNoThumbnail(
        mediaFetchType: MediaFetchType,
        date: Date,
        ascending: Bool
    ) -> [Media]
    
    /// Media 배열 이벤트를 반환합니다.
    func fetchMedias(from assetIdentifiers: [String]) -> Observable<[Media]>
    
    /// 현재 fetchResult를 기준으로 앨범을 저장합니다.
    func saveAlbum(title: String, option: AlbumSaveOption?, sectionMediaList: SectionMediaList, excludeAssets: [String]) throws
    
    /// 사진을 삭제 후 결과 이벤트를 반환합니다.
    func deletePhotos(from assetIdentifiers: [String]) -> Observable<Bool>
}
