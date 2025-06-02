//
//  MediaDetailViewModel.swift
//  poporazzi
//
//  Created by 김민준 on 5/26/25.
//

import UIKit
import RxSwift
import RxCocoa

final class MediaDetailViewModel: ViewModel {
    
    @Dependency(\.persistenceService) private var persistenceService
    @Dependency(\.photoKitService) private var photoKitService
    
    private let output: Output
    
    let disposeBag = DisposeBag()
    let navigation = PublishRelay<Navigation>()
    let menuAction = PublishRelay<MenuAction>()
    let actionSheetAction = PublishRelay<ActionSheetAction>()
    
    /// 이미지 업데이트를 받았는지 확인하는 마킹 배열
    private var updateMarkingList = [Bool]()
    
    init(output: Output) {
        self.output = output
    }
    
    deinit {
        Log.print(#file, .deinit)
    }
}

// MARK: - Input & Output

extension MediaDetailViewModel {
    
    struct Input {
        let viewDidLoad: Signal<Void>
        let currentIndex: Signal<Int>
        let currentScrollOffset: Signal<CGPoint>
        let favoriteButtonTapped: Signal<Void>
        let excludeButtonTapped: Signal<Void>
        let removeButtonTapped: Signal<Void>
        let backButtonTapped: Signal<Void>
    }
    
    struct Output {
        let dataType: BehaviorRelay<DataType>
        let initialIndex: BehaviorRelay<Int>
        let currentIndex: BehaviorRelay<Int>
        
        let mediaList: BehaviorRelay<[Media]>
        let thumbnailList = BehaviorRelay<[Media: UIImage?]>(value: [:])
        
        let updateMediaInfo = BehaviorRelay<(Media, dayCount: Int, Date)>(value: (.initialValue, 0, .now))
        let updateCountInfo = BehaviorRelay<(currentIndex: Int, totalCount: Int)>(value: (0, 0))
        
        let viewDidRefresh = PublishRelay<Void>()
        let toggleLoading = PublishRelay<Bool>()
        
        let setupSeeMoreMenu = BehaviorRelay<[MenuModel]>(value: [])
        let alertPresented = PublishRelay<AlertModel>()
        let actionSheetPresented = PublishRelay<ActionSheetModel>()
    }
    
    enum Navigation {
        case dismiss
        case updateRecord(Record)
        case presentMediaShareSheet([Any])
    }
    
    enum MenuAction {
        case share
    }
    
    enum ActionSheetAction {
        case exclude([Media])
        case remove([Media])
    }
}

// MARK: - Transform

extension MediaDetailViewModel {
    
    func transform(_ input: Input) -> Output {
        input.viewDidLoad
            .asObservable()
            .bind(with: self) { owner, _ in
                owner.output.setupSeeMoreMenu.accept(owner.seemoreToolbarMenu)
            }
            .disposed(by: disposeBag)
        
        // 기본 미디어 리스트 업데이트
        Signal.merge(
            output.viewDidRefresh.asSignal(),
            photoKitService.photoLibraryAssetChange
        )
        .asObservable()
        .bind(with: self) { owner, _ in
            do {
                let mediaList = try owner.fetchAllMediaListWithNoThumbnail()
                if mediaList.isEmpty {
                    owner.navigation.accept(.dismiss)
                } else {
                    owner.output.mediaList.accept(mediaList)
                }
            } catch {
                print(error)
            }
        }
        .disposed(by: disposeBag)
        
        // 기본 정보 및 이미지 불러오기
        output.mediaList
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .userInteractive))
            .withUnretained(self)
            .flatMap { owner, mediaList in
                var index = owner.output.initialIndex.value
                if index >= mediaList.count { index -= 1 }
                
                let media = mediaList[index]
                let creationDate = media.creationDate ?? .now
                let dayCount = owner.days(from: creationDate)
                
                owner.output.updateMediaInfo.accept((media, dayCount, creationDate))
                owner.output.updateCountInfo.accept((index, mediaList.count))
                owner.updateMarkingList = Array(repeating: false, count: mediaList.count)
                
                var updateMediaList = [Media]()
                if index == 0 {
                    updateMediaList = owner.calcForFetchMediaList(displayRow: index)
                } else {
                    owner.updateMarkingList[index] = true
                    updateMediaList = [media]
                }
                return owner.photoKitService.fetchMediaListWithThumbnail(
                    from: updateMediaList.map(\.id),
                    option: .high
                )
            }
            .observe(on: MainScheduler.asyncInstance)
            .bind(with: self) { owner, mediaList in
                var thumbnailList = [Media: UIImage?]()
                mediaList.forEach { thumbnailList.updateValue($0.thumbnail, forKey: $0) }
                owner.output.thumbnailList.accept(thumbnailList)
            }
            .disposed(by: disposeBag)
        
        // 페이지네이션 이미지 불러오기
        input.currentIndex
            .asObservable()
            .distinctUntilChanged()
            .skip(1)
            .withUnretained(self)
            .flatMap { owner, index in
                owner.output.initialIndex.accept(index)
                owner.output.currentIndex.accept(index)
                let mediaList = owner.calcForFetchMediaList(displayRow: index)
                return owner.photoKitService.fetchMediaListWithThumbnail(
                    from: mediaList.map(\.id),
                    option: .high
                )
            }
            .bind(with: self) { owner, mediaList in
                if mediaList.isEmpty { return }
                var thumbnailList = owner.thumbnailList
                mediaList.forEach { thumbnailList.updateValue($0.thumbnail, forKey: $0) }
                owner.output.thumbnailList.accept(thumbnailList)
            }
            .disposed(by: disposeBag)
        
        // 페이지네이션 정보 업데이트
        output.currentIndex
            .skip(1)
            .bind(with: self) { owner, index in
                let media = owner.mediaList[index]
                let creationDate = media.creationDate ?? .now
                let dayCount = owner.days(from: creationDate)
                owner.output.updateMediaInfo.accept((media, dayCount, creationDate))
                owner.output.updateCountInfo.accept((index, owner.mediaList.count))
            }
            .disposed(by: disposeBag)
        
        input.currentScrollOffset
            .filter { $0.y <= -72 }
            .distinctUntilChanged()
            .emit(with: self) { owner, point in
                owner.navigation.accept(.dismiss)
            }
            .disposed(by: disposeBag)
        
        input.favoriteButtonTapped
            .emit(with: self) { owner, _ in
                let media = owner.output.mediaList.value[owner.currentIndex]
                owner.photoKitService.toggleMediaFavorite(
                    from: [media.id],
                    isFavorite: !media.isFavorite
                )
                if !media.isFavorite {
                    HapticManager.impact(style: .soft)
                }
            }
            .disposed(by: disposeBag)
        
        input.excludeButtonTapped
            .emit(with: self) { owner, _ in
                let media = owner.output.mediaList.value[owner.currentIndex]
                let actionSheet = owner.excludeActionSheet(from: [media])
                owner.output.actionSheetPresented.accept(actionSheet)
                HapticManager.notification(type: .warning)
            }
            .disposed(by: disposeBag)
        
        input.removeButtonTapped
            .emit(with: self) { owner, _ in
                let media = owner.output.mediaList.value[owner.currentIndex]
                let actionSheet = owner.removeActionSheet(from: [media])
                owner.output.actionSheetPresented.accept(actionSheet)
                HapticManager.notification(type: .warning)
            }
            .disposed(by: disposeBag)
        
        input.backButtonTapped
            .emit(with: self) { owner, _ in
                owner.navigation.accept(.dismiss)
            }
            .disposed(by: disposeBag)
        
        menuAction
            .bind(with: self) { owner , action in
                switch action {
                case .share:
                    let media = owner.output.mediaList.value[owner.currentIndex]
                    owner.photoKitService.fetchShareItemList(from: [media.id])
                        .bind { shareItemList in
                            owner.navigation.accept(.presentMediaShareSheet(shareItemList))
                        }
                        .disposed(by: owner.disposeBag)
                }
            }
            .disposed(by: disposeBag)
        
        actionSheetAction
            .bind(with: self) { owner, action in
                switch action {
                case let .exclude(mediaList):
                    switch owner.dataType {
                    case let .album(album):
                        owner.photoKitService.excludePhotos(
                            from: album,
                            to: mediaList.map(\.id)
                        )
                        .observe(on: MainScheduler.asyncInstance)
                        .bind { isSucess in
                            
                        }
                        .disposed(by: owner.disposeBag)
                        
                    case let .record(record):
                        var record = record
                        record.excludeMediaList.formUnion(mediaList.map(\.id))
                        owner.output.dataType.accept(.record(record))
                        owner.output.viewDidRefresh.accept(())
                        owner.navigation.accept(.updateRecord(record))
                        owner.persistenceService.updateAlbumExcludeMediaList(to: record)
                    }
                    
                case let .remove(mediaList):
                    owner.output.toggleLoading.accept(true)
                    
                    let identifiers = mediaList.map(\.id)
                    owner.photoKitService.removePhotos(from: identifiers)
                        .observe(on: MainScheduler.asyncInstance)
                        .bind { isSuccess in
                            if isSuccess {
                                switch owner.dataType {
                                case let .album(album):
                                    owner.output.dataType.accept(.album(album))
                                    
                                case let .record(record):
                                    var record = record
                                    record.excludeMediaList.subtract(identifiers)
                                    owner.output.dataType.accept(.record(record))
                                    owner.persistenceService.updateAlbumExcludeMediaList(to: record)
                                }
                            } else {
                                owner.output.alertPresented.accept(owner.removeFailedAlert)
                            }
                            owner.output.toggleLoading.accept(false)
                        }
                        .disposed(by: owner.disposeBag)
                }
                
            }
            .disposed(by: disposeBag)
        
        return output
    }
}

// MARK: - Syntax Sugar

extension MediaDetailViewModel {
    
    var dataType: DataType {
        output.dataType.value
    }
    
    var mediaList: [Media] {
        output.mediaList.value
    }
    
    var thumbnailList: [Media: UIImage?] {
        output.thumbnailList.value
    }
    
    var currentIndex: Int {
        output.currentIndex.value
    }
}

// MARK: - Helper

extension MediaDetailViewModel {
    
    /// 시작날짜를 기준으로 생성일이 몇일차인지 반환합니다.
    private func days(from creationDate: Date) -> Int {
        var startDate = Date()
        switch dataType {
        case .album: return 0
        case let .record(record): startDate = record.startDate
        }
        
        let calendar = Calendar.current
        let components = calendar.dateComponents(
            [.day],
            from: calendar.startOfDay(for: startDate),
            to: calendar.startOfDay(for: creationDate)
        )
        return (components.day ?? 0) + 1
    }
    
    /// 페이지네이션에 필요한 MediaList를 계산합니다.
    private func calcForFetchMediaList(displayRow: Int) -> [Media] {
        let mediaList = output.mediaList.value
        var fetchMediaList: [Media] = []
        
        if let currentMedia = mediaList[safe: displayRow],
           !updateMarkingList[displayRow] {
            fetchMediaList.append(currentMedia)
            updateMarkingList[displayRow] = true
        }
        
        for i in 1...1 {
            let previousIndex = displayRow - i
            let nextIndex = displayRow + i
            
            if let previousMedia = mediaList[safe: previousIndex],
               !updateMarkingList[previousIndex] {
                fetchMediaList.append(previousMedia)
                updateMarkingList[previousIndex] = true
            }
            
            if let nextMedia = mediaList[safe: nextIndex],
               !updateMarkingList[nextIndex] {
                fetchMediaList.append(nextMedia)
                updateMarkingList[nextIndex] = true
            }
        }
        
        return fetchMediaList
    }
    
    /// 선택한 미디어를 고화질 이미지와 함께 반환합니다.
    private func mediaListWithImage(
        from mediaList: [Media]
    ) -> Observable<[Media]> {
        photoKitService.fetchMediaListWithThumbnail(from: mediaList.map(\.id), option: .high)
    }
    
    /// 썸네일 없이 전체 Media 리스트를 반환합니다.
    ///
    /// - 제외된 사진을 필터링합니다.
    /// - 스크린샷이 제외되었을 때 필터링합니다.
    private func fetchAllMediaListWithNoThumbnail() throws -> [Media] {
        switch dataType {
        case let .album(album):
            return photoKitService.fetchMediaList(from: album)
            
        case let .record(record):
            return try photoKitService.fetchMediaList(from: record)
                .filter { !Set(record.excludeMediaList).contains($0.id) }
        }
    }
}

// MARK: - Alert

extension MediaDetailViewModel {
    
    /// 기록 삭제 실패 Alert
    private var removeFailedAlert: AlertModel {
        AlertModel(
            title: "사진을 삭제할 수 없어요",
            message: "사진 라이브러리 권한을 확인해주세요",
            eventButton: .init(title: "확인")
        )
    }
}

// MARK: - Action Sheet

extension MediaDetailViewModel {
    
    /// 앨범 제외 Action Sheet
    private func excludeActionSheet(from mediaList: [Media]) -> ActionSheetModel {
        var title = ""
        switch dataType {
        case let .album(album): title = album.title
        case let .record(record): title = record.title
        }
        
        return ActionSheetModel(
            message: "선택한 기록이 ‘\(title)’ 앨범에서 제외돼요. 나중에 언제든지 다시 추가할 수 있어요.",
            buttons: [
                .init(title: "\(mediaList.count)장의 기록 앨범에서 제외", style: .default) { [weak self] in
                    self?.actionSheetAction.accept(.exclude(mediaList))
                },
                .init(title: "취소", style: .cancel)
            ]
        )
    }
    
    /// 기록 삭제 Action Sheet
    private func removeActionSheet(from mediaList: [Media]) -> ActionSheetModel {
        ActionSheetModel(
            message: "선택한 기록이 ‘사진’ 앱에서 삭제돼요. 삭제한 항목은 사진 앱의 ‘최근 삭제된 항목’에 30일간 보관돼요.",
            buttons: [
                .init(title: "\(mediaList.count)장의 기록 삭제", style: .destructive) { [weak self] in
                    self?.actionSheetAction.accept(.remove(mediaList))
                },
                .init(title: "취소", style: .cancel)
            ]
        )
    }
}

// MARK: - Menu

extension MediaDetailViewModel {
    
    /// 더보기 툴바 버튼 Menu
    private var seemoreToolbarMenu: [MenuModel] {
        let share = MenuModel(symbol: .share, title: "공유하기") { [weak self] in
            self?.menuAction.accept(.share)
        }
        return [share]
    }
}
