//
//  PhotoKitService.swift
//  poporazzi
//
//  Created by 김민준 on 4/8/25.
//

import UIKit
import RxSwift
import Photos

final class PhotoKitService: NSObject {
    
    /// 미디어 검색 타입
    enum MediaFetchType {
        case all
        case image
        case video
    }
    
    /// PhotoKit에서 발생할 수 있는 에러
    enum PhotoKitError: Error {
        case emptyAssets
    }
    
    override init() {
        super.init()
        PHPhotoLibrary.shared().register(self)
    }
}

// MARK: - UseCase

extension PhotoKitService {
    
    /// PhotoLibrary 권한을 요청합니다.
    func requestAuth() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            print(status)
        }
    }
    
    /// PHFetchResult를 날짜에 맞게 반환합니다.
    func fetchAssetResult(
        mediaFetchType: MediaFetchType,
        date: Date,
        ascending: Bool
    ) -> PHFetchResult<PHAsset> {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = makePredicate(mediaFetchType: mediaFetchType, date: date)
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: ascending)]
        return PHAsset.fetchAssets(with: fetchOptions)
    }
    
    /// 기록을 반환합니다.
    func fetchPhotos(_ fetchResult: PHFetchResult<PHAsset>?) -> Observable<[Media]> {
        return Observable.create { observer in
            var newMedias = [Media]()
            let imageManager = PHImageManager.default()
            let requestOptions = PHImageRequestOptions()
            requestOptions.isSynchronous = true
            requestOptions.deliveryMode = .highQualityFormat
            
            fetchResult?.enumerateObjects { asset, _, _ in
                imageManager.requestImage(
                    for: asset,
                    targetSize: .init(width: 360, height: 360),
                    contentMode: .aspectFill,
                    options: requestOptions,
                    resultHandler: { image, _ in
                        if let image = image {
                            let media = Media(
                                id: asset.localIdentifier,
                                mediaType: asset.mediaType == .image ? .photo : .video(duration: asset.duration),
                                thumbnail: image
                            )
                            newMedias.append(media)
                        }
                    }
                )
            }
            
            observer.onNext(newMedias)
            observer.onCompleted()
            return Disposables.create()
        }
    }
    
    /// 앨범에 기록을 저장합니다.
    func saveAlbum(title: String, assets: PHFetchResult<PHAsset>?) throws {
        
        guard let assets = assets else { throw PhotoKitError.emptyAssets }
        
        // 기존 앨범에 추가
        if let album = fetchAlbum(title: title) {
            appendToAlbum(assets: assets, to: album)
        }
        
        // 앨범 새로 생성
        else {
            PHPhotoLibrary.shared().performChanges {
                PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: title)
            } completionHandler: { [weak self] isSuccess, error in
                guard let self else { return }
                guard let album = fetchAlbum(title: title) else { return }
                appendToAlbum(assets: assets, to: album)
            }
        }
    }
}

// MARK: - Helper

extension PhotoKitService {
    
    /// 미디어 패치를 위한 Predicate 객체를 생성합니다.
    private func makePredicate(mediaFetchType: MediaFetchType, date: Date) -> NSPredicate {
        let dateFormat = "creationDate > %@"
        let mediaFormat = "mediaType == %d"
        switch mediaFetchType {
        case .all:
            return .init(
                format: "(\(mediaFormat) OR \(mediaFormat))" + " AND " + dateFormat,
                PHAssetMediaType.image.rawValue,
                PHAssetMediaType.video.rawValue,
                date as NSDate
            )
        case .image:
            return .init(
                format: mediaFormat + " AND " + dateFormat,
                PHAssetMediaType.image.rawValue,
                date as NSDate
            )
        case .video:
            return .init(
                format: mediaFormat + " AND " + dateFormat,
                PHAssetMediaType.video.rawValue,
                date as NSDate
            )
        }
    }
    
    /// 앨범을 반환합니다.
    private func fetchAlbum(title: String) -> PHAssetCollection? {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", title)
        return PHAssetCollection.fetchAssetCollections(
            with: .album,
            subtype: .any,
            options: fetchOptions
        ).firstObject
    }
    
    /// 앨범에 추가합니다.
    private func appendToAlbum(assets: PHFetchResult<PHAsset>, to album: PHAssetCollection) {
        PHPhotoLibrary.shared().performChanges {
            let request = PHAssetCollectionChangeRequest(for: album)
            request?.addAssets(assets)
        }
    }
}

// MARK: - PHPhotoLibraryChangeObserver

extension PhotoKitService: PHPhotoLibraryChangeObserver {
    
    /// PhotoLibrary의 변화 감지 시 호출됩니다.
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        print(changeInstance)
    }
}
