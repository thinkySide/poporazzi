//
//  MockPhotoKitService.swift
//  poporazzi
//
//  Created by 김민준 on 5/7/25.
//

import UIKit
import RxSwift
import RxCocoa
import Photos

struct MockPhotoKitService: PhotoKitInterface {
    
    var photoLibraryChange: Signal<Void> {
        PublishRelay<Void>().asSignal()
    }
    
    func checkAuth() -> PHAuthorizationStatus {
        .authorized
    }
    
    func requestAuth() -> Observable<PHAuthorizationStatus> {
        .just(.authorized)
    }
    
    func fetchMediaListWithNoThumbnail(from album: Album) -> [Media] {
        Array(repeatElement(.init(
            id: UUID().uuidString,
            creationDate: .now,
            mediaType: .photo(.selfShooting, .heic),
            isFavorite: false
        ), count: 30))
    }
    
    func fetchMedias(from assetIdentifiers: [String]) -> Observable<[Media]> {
        var array = [Media]()
        for _ in 0..<30 {
            array.append(.init(
                id: UUID().uuidString,
                creationDate: .now,
                mediaType: .photo(.selfShooting, .heic),
                thumbnail: UIImage(),
                isFavorite: false
            ))
        }
        return .just(array)
    }
    
    func toggleFavorite(from assetIdentifiers: [String], isFavorite: Bool) {
        print("즐겨찾기 완료")
    }
    
    func saveAlbumAsSingle(title: String, sectionMediaList: SectionMediaList)  -> Observable<Void> {
        print("[하나의 앨범으로 저장 완료] - \(title)")
        return .just(())
    }
    
    func saveAlubmByDay(title: String, sectionMediaList: SectionMediaList) -> Observable<Void> {
        print("[일차별 앨범으로 저장 완료] - \(title)")
        return .just(())
    }
    
    func deletePhotos(from assetIdentifiers: [String]) -> Observable<Bool> {
        .just(true)
    }
    
    func fetchShareItemList(from assetIdentifiers: [String]) -> Observable<[Any]> {
        .just([])
    }
}
