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
        Array(repeatElement(Media(id: UUID().uuidString, creationDate: .now, mediaType: .photo), count: 30))
    }
    
    func fetchMedias(from assetIdentifiers: [String]) -> Observable<[Media]> {
        var array = [Media]()
        for _ in 0..<30 {
            array.append(Media(id: UUID().uuidString, creationDate: .now, mediaType: .photo, thumbnail: UIImage()))
        }
        return .just(array)
    }
    
    func saveAlbumAsSingle(title: String, excludeAssets: [String]) throws {
        print("[하나의 앨범으로 저장 완료] - \(title)")
    }
    
    func saveAlubmByDay(title: String, sectionMediaList: SectionMediaList, excludeAssets: [String]) -> Observable<Void> {
        print("[일차별 앨범으로 저장 완료] - \(title)")
        return .just(())
    }
    
    func deletePhotos(from assetIdentifiers: [String]) -> Observable<Bool> {
        .just(true)
    }
}
