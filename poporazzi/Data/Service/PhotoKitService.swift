//
//  PhotoKitService.swift
//  poporazzi
//
//  Created by 김민준 on 4/8/25.
//

import UIKit
import RxSwift
import Photos

struct PhotoKitService {
    
    enum MediaFetchType {
        case all
        case image
        case video
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
    func fetchPhotos(_ fetchResult: PHFetchResult<PHAsset>?) -> Observable<[Photo]> {
        var newImages = [UIImage]()
        let imageManager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        requestOptions.deliveryMode = .highQualityFormat
        
        fetchResult?.enumerateObjects { asset, _, _ in
            imageManager.requestImage(
                for: asset,
                targetSize: .zero,
                contentMode: .aspectFit,
                options: requestOptions,
                resultHandler: { image, _ in
                    if let image = image {
                        newImages.append(image)
                    }
                }
            )
        }
        
        return .just(newImages.map { Photo(content: $0) })
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
}
