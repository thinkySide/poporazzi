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
        Array(repeatElement(Media(id: UUID().uuidString, mediaType: .photo), count: 30))
    }
    
    func fetchMedias(from assetIdentifiers: [String]) -> Observable<[OrderedMedia]> {
        var array = [OrderedMedia]()
        for i in 0..<30 {
            array.append((i, Media(id: UUID().uuidString, mediaType: .photo, thumbnail: UIImage())))
        }
        return .just(array)
    }
    
    func saveAlbum(title: String) throws {
        print("[앨범 저장 완료] - \(title)")
    }
    
    func deletePhotos(from assetIdentifiers: [String]) -> Observable<Bool> {
        .just(true)
    }
}
