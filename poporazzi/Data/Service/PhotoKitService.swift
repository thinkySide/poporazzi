//
//  PhotoKitService.swift
//  poporazzi
//
//  Created by 김민준 on 4/8/25.
//

import UIKit
import RxSwift
import Photos

struct PhotoKitService: PhotoRepository {
    
}

// MARK: - Interface Function

extension PhotoKitService {
    
    func requestAuth() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            print(status)
        }
    }
    
    func fetchPhotos(from date: Date) -> Observable<[Photo]> {
        let predicate = NSPredicate(format: "creationDate > %@", date as NSDate)
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = predicate
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        
        let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        // self.fetchResult = fetchResult
        
        var newImages = [UIImage]()
        let imageManager = PHImageManager.default()
        
        fetchResult.enumerateObjects { asset, _, _ in
            imageManager.requestImage(
                for: asset,
                targetSize: .init(width: 200, height: 200),
                contentMode: .aspectFill,
                options: nil,
                resultHandler: { image, _ in
                    if let image = image {
                        newImages.append(image)
                    }
                }
            )
        }
        
        print("새롭게 생성된 이미지 개수: \(newImages.count)")
        return .just(newImages.map { Photo(content: $0) })
    }
}
