//
//  MockPhotoKitService.swift
//  poporazzi
//
//  Created by 김민준 on 5/7/25.
//

import UIKit
import RxSwift
import RxCocoa

struct MockPhotoKitService: PhotoKitInterface {
    
    var photoLibraryChange: Signal<Void> {
        PublishRelay<Void>().asSignal()
    }
    
    func requestAuth() {
        print("[권한 허용 완료]")
    }
    
    func fetchMediasWithNoThumbnail(mediaFetchType: MediaFetchType, date: Date, ascending: Bool) -> [Media] {
        [
            Media(id: "0", mediaType: .photo),
            Media(id: "1", mediaType: .photo),
            Media(id: "2", mediaType: .video(duration: 1000)),
            Media(id: "3", mediaType: .photo),
            Media(id: "4", mediaType: .photo),
            Media(id: "5", mediaType: .video(duration: 2000)),
            Media(id: "6", mediaType: .photo),
            Media(id: "7", mediaType: .photo),
            Media(id: "8", mediaType: .video(duration: 3000)),
            Media(id: "9", mediaType: .photo)
        ]
    }
    
    func fetchMedias(from assetIdentifiers: [String]) -> Observable<[OrderedMedia]> {
        .just([
            OrderedMedia(0, .init(id: "0", mediaType: .photo, thumbnail: UIImage())),
            OrderedMedia(1, .init(id: "1", mediaType: .photo, thumbnail: UIImage())),
            OrderedMedia(2, .init(id: "2", mediaType: .video(duration: 1000))),
            OrderedMedia(3, .init(id: "3", mediaType: .photo, thumbnail: UIImage())),
            OrderedMedia(4, .init(id: "4", mediaType: .photo, thumbnail: UIImage())),
            OrderedMedia(5, .init(id: "5", mediaType: .video(duration: 2000), thumbnail: UIImage())),
            OrderedMedia(6, .init(id: "6", mediaType: .photo, thumbnail: UIImage())),
            OrderedMedia(7, .init(id: "7", mediaType: .photo, thumbnail: UIImage())),
            OrderedMedia(8, .init(id: "8", mediaType: .video(duration: 3000), thumbnail: UIImage())),
            OrderedMedia(9, .init(id: "9", mediaType: .photo, thumbnail: UIImage())),
        ])
    }
    
    func saveAlbum(title: String) throws {
        print("[앨범 저장 완료] - \(title)")
    }
    
    func deletePhotos(from assetIdentifiers: [String]) -> Observable<Bool> {
        .just(true)
    }
}
