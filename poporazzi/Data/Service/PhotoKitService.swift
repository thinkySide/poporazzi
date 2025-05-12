//
//  PhotoKitService.swift
//  poporazzi
//
//  Created by 김민준 on 4/8/25.
//

import UIKit
import RxSwift
import RxCocoa
import Photos

final class PhotoKitService: NSObject, PhotoKitInterface {
    
    /// PhotoKit에서 발생할 수 있는 에러
    enum PhotoKitError: Error {
        case noPermission
        case emptyAssets
    }
    
    /// 기본 PH 요청 옵션
    private var defaultFetchOptions: PHFetchOptions = {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        return fetchOptions
    }()
    
    /// 기본 이미지 요청 옵션
    private var defaultImageRequestOptions: PHImageRequestOptions = {
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = false
        requestOptions.deliveryMode = .highQualityFormat
        return requestOptions
    }()
    
    /// 가장 최근의 FetchResult를 저장하는 변수
    private var fetchResult: PHFetchResult<PHAsset>?
    
    /// PhotoLibray의 변화가 감지할 때 이벤트를 발송하는 Relay
    private let photoLibraryChangeRelay = BehaviorRelay(value: ())
    
    override init() {
        super.init()
        PHPhotoLibrary.shared().register(self)
    }
}

// MARK: - UseCase

extension PhotoKitService {
    
    /// PhotoLibrayChangeRelay를 Signal로 반환
    var photoLibraryChange: Signal<Void> {
        photoLibraryChangeRelay.asSignal(onErrorJustReturn: ())
    }
    
    /// PhotoLibrary 권한을 요청합니다.
    func requestAuth() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            print(status)
        }
    }
    
    /// 썸네일 없이 기록을 반환합니다.
    func fetchMediasWithNoThumbnail(
        mediaFetchType: MediaFetchType = .all,
        date: Date,
        ascending: Bool = true
    ) -> [Media] {
        var newMedias = [Media]()
        
        let fetchAssetResult = self.fetchAssetResult(
            mediaFetchType: mediaFetchType,
            date: date,
            ascending: ascending
        )
        fetchResult = fetchAssetResult
        
        fetchResult?.enumerateObjects { asset, _, _ in
            let media = Media(
                id: asset.localIdentifier,
                creationDate: asset.creationDate,
                mediaType: asset.mediaType == .image ? .photo : .video(duration: asset.duration),
                thumbnail: nil
            )
            newMedias.append(media)
        }
        return newMedias
    }
    
    /// Asset Identifier를 기준으로 Media 배열을 반환합니다.
    func fetchMedias(from assetIdentifiers: [String]) -> Observable<[Media]> {
        Observable.create { [weak self] observer in
            Task {
                guard let self else {
                    observer.onCompleted()
                    return
                }
                
                let fetchResult = PHAsset.fetchAssets(
                    withLocalIdentifiers: assetIdentifiers,
                    options: nil
                )
                
                var assetMap = [String: PHAsset]()
                fetchResult.enumerateObjects { asset, _, _ in
                    assetMap[asset.localIdentifier] = asset
                }
                
                let orderedAsset = assetIdentifiers.compactMap { assetMap[$0] }
                
                let medias: [Media] = await withTaskGroup(of: Media.self) { group in
                    for asset in orderedAsset {
                        group.addTask {
                            let image = await self.requestImage(for: asset)
                            return Media(
                                id: asset.localIdentifier,
                                creationDate: asset.creationDate,
                                mediaType: asset.mediaType == .image ? .photo : .video(duration: asset.duration),
                                thumbnail: image
                            )
                        }
                    }
                    var array: [Media] = []
                    for await i in group { array.append(i) }
                    return array.sortedByCreationDate
                }
                
                observer.onNext(medias)
                observer.onCompleted()
            }
            
            return Disposables.create()
        }
    }
    
    /// 하나의 앨범으로 만들어 저장합니다.
    func saveAlbumAsSingle(title: String, excludeAssets: [String]) throws {
        guard let filteredFetchResult = try filterExcludeAssets(excludeAssets) else { return }
        
        Task {
            let albumIdentifier = await createAlbum(title: title)
            guard let album = fetchAlbum(from: albumIdentifier) else { return }
            appendToAlbum(filteredFetchResult, to: album)
        }
    }
    
    /// 일차별 앨범을 생성 후 폴더에 넣어 저장합니다.
    func saveAlubmByDay(title: String, sectionMediaList: SectionMediaList, excludeAssets: [String]) -> Observable<Void> {
        Observable.create { observer in
            Task {
                let folderIdentifier = await self.createFolder(title: title)
                guard let folder = self.fetchFolder(from: folderIdentifier) else { return }
                
                // 각 일차 병렬 처리로 생성
                let albumList = await withTaskGroup(of: (Int, PHAssetCollection?).self) { group in
                    for (index, (section, mediaList)) in sectionMediaList.enumerated() {
                        
                        group.addTask {
                            // 1. Section 기준으로 FetchResult 생성
                            let assetIdentifiers = mediaList.map { $0.id }
                            let fetchResult = PHAsset.fetchAssets(
                                withLocalIdentifiers: assetIdentifiers,
                                options: self.defaultFetchOptions
                            )
                            
                            // 2. 앨범 생성 및 추가
                            let albumIdentifier = await self.createAlbum(title: section.dateFormat)
                            guard let album = self.fetchAlbum(from: albumIdentifier) else { return (index, nil) }
                            self.appendToAlbum(fetchResult, to: album)
                            
                            return (index, album)
                        }
                    }
                    
                    var albumList = [(Int, PHAssetCollection)]()
                    for await item in group {
                        if let album = item.1 {
                            albumList.append((item.0, album))
                        }
                    }
                    
                    return albumList.sorted { $0.0 < $1.0 }
                }
                
                // 3. 폴더에 앨범 추가
                for (_, album) in albumList {
                    try await self.appendToFolder(album, to: folder)
                }
                
                observer.onNext(())
                observer.onCompleted()
            }
            
            return Disposables.create()
        }
    }
    
    /// 주어진 ID의 사진을 삭제합니다.
    func deletePhotos(from assetIdentifiers: [String]) -> Observable<Bool> {
        return Observable.create { observer in
            let assets = PHAsset.fetchAssets(withLocalIdentifiers: assetIdentifiers, options: nil)
            PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.deleteAssets(assets)
            } completionHandler: { isSuccess, _ in
                observer.onNext(isSuccess)
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
}

// MARK: - Album

extension PhotoKitService {
    
    /// 앨범 생성 후 앨범의 identifier를 반환합니다.
    private func createAlbum(title: String) async -> String {
        let identifier = await withCheckedContinuation { continuation in
            var albumIdentifier: String?
            PHPhotoLibrary.shared().performChanges {
                let request = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: title)
                albumIdentifier = request.placeholderForCreatedAssetCollection.localIdentifier
            } completionHandler: { isSuccess, error in
                continuation.resume(returning: albumIdentifier)
            }
        }
        
        return identifier ?? ""
    }
    
    /// 앨범을 반환합니다.
    private func fetchAlbum(from locaIdentifier: String) -> PHAssetCollection? {
        PHAssetCollection.fetchAssetCollections(
            withLocalIdentifiers: [locaIdentifier],
            options: nil
        )
        .firstObject
    }
}

// MARK: - Folder

extension PhotoKitService {
    
    /// 폴더 생성 후 폴더의 identifier를 반환합니다.
    private func createFolder(title: String) async -> String {
        let identifier = await withCheckedContinuation { continuation in
            var folderIdentifier: String?
            PHPhotoLibrary.shared().performChanges {
                let request = PHCollectionListChangeRequest.creationRequestForCollectionList(withTitle: title)
                folderIdentifier = request.placeholderForCreatedCollectionList.localIdentifier
            } completionHandler: { isSuccess, error in
                continuation.resume(returning: folderIdentifier)
            }
        }
        
        return identifier ?? ""
    }
    
    /// 폴더를 반환합니다.
    private func fetchFolder(from locaIdentifier: String) -> PHCollectionList? {
        PHCollectionList.fetchCollectionLists(
            withLocalIdentifiers: [locaIdentifier], options: nil
        )
        .firstObject
    }
}

// MARK: - Helper

extension PhotoKitService {
    
    /// PHFetchResult를 날짜에 맞게 반환합니다.
    private func fetchAssetResult(
        mediaFetchType: MediaFetchType,
        date: Date,
        ascending: Bool
    ) -> PHFetchResult<PHAsset> {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = makePredicate(mediaFetchType: mediaFetchType, date: date)
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: ascending)]
        return PHAsset.fetchAssets(with: fetchOptions)
    }
    
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
    
    /// 이미지를 비동기로 요청합니다.
    private func requestImage(for asset: PHAsset) async -> UIImage? {
        await withCheckedContinuation { continuation in
            PHImageManager.default().requestImage(
                for: asset,
                targetSize: CGSize(width: 360, height: 360),
                contentMode: .aspectFill,
                options: self.defaultImageRequestOptions
            ) { image, _ in
                continuation.resume(returning: image)
            }
        }
    }
    
    /// 현재 에셋을 필터링 후 반환합니다.
    private func filterExcludeAssets(_ excludeAssets: [String]) throws -> PHFetchResult<PHAsset>? {
        guard let fetchResult else { throw PhotoKitError.emptyAssets }
        
        let allAssets = (0..<fetchResult.count).compactMap { fetchResult.object(at: $0) }
        
        let filteredIdentifiers = allAssets
            .filter { !Set(excludeAssets).contains($0.localIdentifier) }
            .map { $0.localIdentifier }
        
        return PHAsset.fetchAssets(withLocalIdentifiers: filteredIdentifiers, options: defaultFetchOptions)
    }
    
    /// 앨범에 에셋을 추가합니다.
    private func appendToAlbum(_ fetchResult: PHFetchResult<PHAsset>, to album: PHAssetCollection) {
        PHPhotoLibrary.shared().performChanges {
            let request = PHAssetCollectionChangeRequest(for: album)
            request?.addAssets(fetchResult)
        }
    }
    
    /// 폴더에 앨범을 추가합니다.
    private func appendToFolder(_ album: PHAssetCollection, to folder: PHCollectionList) async throws {
        let _: Void = try await withCheckedThrowingContinuation { continuation in
            PHPhotoLibrary.shared().performChanges {
                let request = PHCollectionListChangeRequest(for: folder)
                request?.addChildCollections([album] as NSFastEnumeration)
            } completionHandler: { isSuccess, error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }
}

// MARK: - PHPhotoLibraryChangeObserver

extension PhotoKitService: PHPhotoLibraryChangeObserver {
    
    /// PhotoLibrary의 변화 감지 시 호출됩니다.
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let fetchResult,
              let changeDetails = changeInstance.changeDetails(for: fetchResult) else {
            return
        }
        
        /// 변화가 일어났는지 확인
        if changeDetails.hasIncrementalChanges {
            
            // 추가 또는 삭제된 에셋이 있다면
            if !changeDetails.insertedObjects.isEmpty || !changeDetails.removedObjects.isEmpty {
                photoLibraryChangeRelay.accept(())
            }
        }
    }
}
