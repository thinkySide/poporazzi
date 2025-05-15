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
    
    /// 감지를 위한 fetchResult
    private var fetchResultForObserve: PHFetchResult<PHAsset>?
    
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
    func fetchMediaListWithNoThumbnail(from album: Album) -> [Media] {
        let fetchResult = fetchAssetResult(from: album)
        self.fetchResultForObserve = fetchResult
        
        var mediaList = [Media]()
        fetchResult.enumerateObjects { [weak self] asset, _, _ in
            guard let self else { return }
            let mediaType = self.mediaType(from: asset)
            let option = album.mediaFilterOption
            
            switch mediaType {
            case let .photo(type, _):
                let isContain = option.isContainSelfShooting && type == .selfShooting
                || option.isContainDownload && type == .download
                || option.isContainScreenshot && type == .screenshot
                
                if isContain {
                    let media = Media(
                        id: asset.localIdentifier,
                        creationDate: asset.creationDate,
                        mediaType: mediaType,
                        thumbnail: nil
                    )
                    mediaList.append(media)
                }
                
            case let .video(type, _, _):
                let isContain = option.isContainSelfShooting && type == .selfShooting
                || option.isContainDownload && type == .download
                
                if isContain {
                    let media = Media(
                        id: asset.localIdentifier,
                        creationDate: asset.creationDate,
                        mediaType: mediaType,
                        thumbnail: nil
                    )
                    mediaList.append(media)
                }
            }
        }
        
        return mediaList
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
                                mediaType: self.mediaType(from: asset),
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
    func saveAlbumAsSingle(title: String, sectionMediaList: SectionMediaList) -> Observable<Void> {
        Observable.create { [weak self] observer in
            guard let self else { return Disposables.create() }
            Task {
                // 1. 하나의 배열로 만들기
                var assetIdentifiers = [String]()
                for (_, mediaList) in sectionMediaList {
                    assetIdentifiers.append(contentsOf: mediaList.map { $0.id })
                }
                
                // 2. 앨범 생성하기
                let albumIdentifier = await self.createAlbum(title: title)
                guard let album = self.fetchAlbum(from: albumIdentifier) else { return }
                let fetchResult = PHAsset.fetchAssets(
                    withLocalIdentifiers: assetIdentifiers,
                    options: self.defaultFetchOptions
                )
                self.appendToAlbum(fetchResult, to: album)
                
                observer.onNext(())
                observer.onCompleted()
            }
            
            return Disposables.create()
        }
    }
    
    /// 일차별 앨범을 생성 후 폴더에 넣어 저장합니다.
    func saveAlubmByDay(title: String, sectionMediaList: SectionMediaList) -> Observable<Void> {
        Observable.create { [weak self] observer in
            guard let self else { return Disposables.create() }
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
        Observable.create { observer in
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
    
    /// 현재 Asset의 MediaType을 반환합니다.
    private func mediaType(from asset: PHAsset) -> MediaType {
        let resources = PHAssetResource.assetResources(for: asset)
        let uniformTypeIdentifier = resources.first?.uniformTypeIdentifier ?? ""
        let format = String(uniformTypeIdentifier.split(separator: ".").last ?? "")
        print(format)
        
        switch asset.mediaType {
        case .image:
            let photoFormat = PhotoFormat(rawValue: format) ?? .heic
            
            if asset.mediaSubtypes.contains(.photoScreenshot) {
                return.photo(.screenshot, photoFormat)
            }
            
            if photoFormat == .heic {
                return .photo(.selfShooting, photoFormat)
            } else {
                return .photo(.download, photoFormat)
            }
            
        case .video:
            let videoFormat = VideoFormat(rawValue: format) ?? .quickTimeMovie
            
            if videoFormat == .quickTimeMovie {
                return .video(.selfShooting, videoFormat, duration: asset.duration)
            } else {
                return .video(.download, videoFormat, duration: asset.duration)
            }
            
        default:
            return .photo(.selfShooting, .heic)
        }
    }
    
    /// PHFetchResult를 날짜에 맞게 반환합니다.
    private func fetchAssetResult(from album: Album) -> PHFetchResult<PHAsset> {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = makePredicate(from: album)
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        return PHAsset.fetchAssets(with: fetchOptions)
    }
    
    /// 미디어 패치를 위한 Predicate 객체를 생성합니다.
    private func makePredicate(from album: Album) -> NSPredicate {
        let dateFormat = "creationDate > %@"
        let mediaFormat = "mediaType == %d"
        
        var format = ""
        var arguments = [CVarArg]()
        
        // 1. 미디어 유형 설정
        switch album.mediaFetchOption {
        case .all:
            format += ("(\(mediaFormat) OR \(mediaFormat))")
            arguments.append(PHAssetMediaType.image.rawValue)
            arguments.append(PHAssetMediaType.video.rawValue)
        case .photo:
            format += mediaFormat
            arguments.append(PHAssetMediaType.image.rawValue)
        case .video:
            format += mediaFormat
            arguments.append(PHAssetMediaType.video.rawValue)
        }
        
        // 2. 시작 날짜 설정
        let result = format + " AND " + dateFormat
        arguments.append(album.startDate as NSDate)
        
        return .init(format: result, argumentArray: arguments)
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
        guard let fetchResultForObserve,
              let changeDetails = changeInstance.changeDetails(for: fetchResultForObserve) else {
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
