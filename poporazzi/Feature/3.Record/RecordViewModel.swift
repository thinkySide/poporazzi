//
//  RecordViewModel.swift
//  poporazzi
//
//  Created by 김민준 on 4/5/25.
//

import UIKit
import Foundation
import RxSwift
import RxCocoa

final class RecordViewModel: ViewModel {
    
    @Dependency(\.liveActivityService) private var liveActivityService
    @Dependency(\.photoKitService) private var photoKitService
    
    private let disposeBag = DisposeBag()
    private let output: Output
    
    private var currentChunk = 0
    private let chunkSize = 100
    
    let navigation = PublishRelay<Navigation>()
    let delegate = PublishRelay<Delegate>()
    let alertAction = PublishRelay<AlertAction>()
    let actionSheetAction = PublishRelay<ActionSheetAction>()
    let menuAction = PublishRelay<MenuAction>()
    
    init(output: Output) {
        self.output = output
    }
    
    deinit {
        Log.print(#file, .deinit)
    }
}

// MARK: - Input & Output

extension RecordViewModel {
    
    struct Input {
        let viewDidLoad: Signal<Void>
        let selectButtonTapped: Signal<Void>
        let selectCancelButtonTapped: Signal<Void>
        let recentIndexPath: BehaviorRelay<IndexPath>
        let recordCellSelected: Signal<IndexPath>
        let recordCellDeselected: Signal<IndexPath>
        let excludeButtonTapped: Signal<Void>
        let removeButtonTapped: Signal<Void>
        let finishButtonTapped: Signal<Void>
    }
    
    struct Output {
        let album: BehaviorRelay<Album>
        
        let mediaFetchType: BehaviorRelay<MediaFetchType>
        let mediaFetchDetailType: BehaviorRelay<[MediaDetialFetchType]>
        
        let mediaList = BehaviorRelay<[Media]>(value: [])
        let sectionMediaList = BehaviorRelay<SectionMediaList>(value: [])
        
        let updateRecordCells = BehaviorRelay<[Media]>(value: [])
        let selectedRecordCells = BehaviorRelay<[IndexPath]>(value: [])
        
        let viewDidRefresh = PublishRelay<Void>()
        let setupSeeMoreMenu = BehaviorRelay<[MenuModel]>(value: [])
        let switchSelectMode = PublishRelay<Bool>()
        let alertPresented = PublishRelay<AlertModel>()
        let actionSheetPresented = PublishRelay<ActionSheetModel>()
        let toggleLoading = PublishRelay<Bool>()
    }
    
    enum Navigation {
        case pop
        case presentAlbumEdit(Album, MediaFetchType, [MediaDetialFetchType])
        case presentExcludeRecord
        case presentFinishModal(Album, SectionMediaList)
    }
    
    enum Delegate {
        case albumDidEdited(Album, MediaFetchType, [MediaDetialFetchType])
        case updateExcludeRecord
    }
    
    enum AlertAction {
        case finishWithoutRecord
    }
    
    enum ActionSheetAction {
        case exclude
        case remove
    }
    
    enum MenuAction {
        case editAlbum
        case excludeRecord
    }
}

// MARK: - Chunk

extension RecordViewModel {
    
    /// 현재 청크를 기준으로 에셋 ID 배열을 반환합니다.
    private var chunkAssetIdentifiers: [String] {
        let chunkStart = min(currentChunk, output.mediaList.value.count)
        let chunkEnd = min(chunkSize + chunkStart, output.mediaList.value.count)
        return output.mediaList.value[chunkStart..<chunkEnd].map { $0.id }
    }
    
    /// 다음 청크로 업데이트합니다.
    private func updateChunk() {
        currentChunk += chunkSize
    }
    
    /// 청크를 초기화합니다.
    private func resetChunk() {
        currentChunk = 0
        output.updateRecordCells.accept([])
    }
}

// MARK: - Transform

extension RecordViewModel {
    
    func transform(_ input: Input) -> Output {
        
        // 1. 화면 진입 시 기본 이미지 로드
        input.viewDidLoad
            .asObservable()
            .do { [weak self] _ in
                guard let self else { return }
                self.output.setupSeeMoreMenu.accept(self.seemoreMenu)
            }
            .observe(on: MainScheduler.asyncInstance)
            .bind(with: self) { owner, _ in
                owner.output.mediaList.accept(owner.fetchAllMediaListWithNoThumbnail())
                
                let assetIdentifiers = owner.chunkAssetIdentifiers
                owner.fetchAllMediaList(from: assetIdentifiers)
                    .observe(on: MainScheduler.asyncInstance)
                    .bind { mediaList in
                        owner.output.updateRecordCells.accept(mediaList)
                    }
                    .disposed(by: owner.disposeBag)
            }
            .disposed(by: disposeBag)
        
        // 2. 업데이트
        input.recentIndexPath
            .filter { !$0.isEmpty }
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .userInteractive))
            .bind(with: self) { owner, indexPath in
                
                let currentIndex = owner.index(from: indexPath)
                guard currentIndex <= owner.output.mediaList.value.count else { return }
                
                // 마지막 셀이 나타나기 전에 업데이트
                if currentIndex >= (owner.currentChunk + owner.chunkSize - 10) {
                    owner.updateChunk()
                    let assetIdentifiers = owner.chunkAssetIdentifiers
                    
                    owner.fetchAllMediaList(from: assetIdentifiers)
                        .observe(on: MainScheduler.asyncInstance)
                        .bind { mediaList in
                            owner.output.updateRecordCells.accept(mediaList)
                        }
                        .disposed(by: owner.disposeBag)
                }
            }
            .disposed(by: disposeBag)
        
        // 3. 리프레쉬 및 라이브러리 변경 감지
        Signal.merge(output.viewDidRefresh.asSignal(), photoKitService.photoLibraryChange)
            .asObservable()
            .bind(with: self) { owner, _ in
                owner.output.mediaList.accept(owner.fetchAllMediaListWithNoThumbnail())
                owner.resetChunk()
                
                let assetIdentifiers = owner.chunkAssetIdentifiers
                owner.fetchAllMediaList(from: assetIdentifiers)
                    .observe(on: MainScheduler.asyncInstance)
                    .bind { mediaList in
                        owner.output.updateRecordCells.accept(mediaList)
                    }
                    .disposed(by: owner.disposeBag)
            }
            .disposed(by: disposeBag)
        
        output.mediaList
            .bind(with: self) { owner, mediaList in
                owner.output.sectionMediaList.accept(owner.dayCountSections(from: mediaList))
                owner.liveActivityService.update(
                    to: owner.output.album.value,
                    totalCount: mediaList.count
                )
            }
            .disposed(by: disposeBag)
        
        input.selectButtonTapped
            .emit(with: self) { owner, _ in
                owner.output.switchSelectMode.accept(true)
                HapticManager.impact(style: .light)
            }
            .disposed(by: disposeBag)
        
        input.selectCancelButtonTapped
            .emit(with: self) { owner, _ in
                owner.output.selectedRecordCells.accept([])
                owner.output.switchSelectMode.accept(false)
                HapticManager.impact(style: .light)
            }
            .disposed(by: disposeBag)
        
        input.recordCellSelected
            .emit(with: self) { owner, indexPath in
                var currentCells = owner.output.selectedRecordCells.value
                currentCells.append(indexPath)
                owner.output.selectedRecordCells.accept(currentCells)
            }
            .disposed(by: disposeBag)
        
        input.recordCellDeselected
            .emit(with: self) { owner, indexPath in
                var currentCells = owner.output.selectedRecordCells.value
                currentCells.removeAll(where: { $0 == indexPath })
                owner.output.selectedRecordCells.accept(currentCells)
            }
            .disposed(by: disposeBag)
        
        input.excludeButtonTapped
            .emit(with: self) { owner, _ in
                owner.output.actionSheetPresented.accept(owner.excludeActionSheet)
                HapticManager.notification(type: .warning)
            }
            .disposed(by: disposeBag)
        
        input.removeButtonTapped
            .emit(with: self) { owner, _ in
                owner.output.actionSheetPresented.accept(owner.removeActionSheet)
                HapticManager.notification(type: .warning)
            }
            .disposed(by: disposeBag)
        
        input.finishButtonTapped
            .emit(with: self) { owner, _ in
                if owner.output.mediaList.value.isEmpty {
                    owner.output.alertPresented.accept(owner.finishWithoutRecordAlert)
                } else {
                    owner.navigation.accept(.presentFinishModal(
                        owner.output.album.value,
                        owner.output.sectionMediaList.value
                    ))
                }
            }
            .disposed(by: disposeBag)
        
        alertAction
            .bind(with: self) { owner, action in
                switch action {
                case .finishWithoutRecord:
                    owner.navigation.accept(.pop)
                    owner.liveActivityService.stop()
                    UserDefaultsService.excludeAssets.removeAll()
                    UserDefaultsService.isTracking = false
                }
            }
            .disposed(by: disposeBag)
        
        actionSheetAction
            .bind(with: self) { owner, action in
                switch action {
                case .exclude:
                    let assetIdentifiers = owner.selectedAssetIdentifiers()
                    UserDefaultsService.excludeAssets.append(contentsOf: assetIdentifiers)
                    owner.output.viewDidRefresh.accept(())
                    owner.output.selectedRecordCells.accept([])
                    
                case .remove:
                    owner.output.toggleLoading.accept(true)
                    let assetIdentifiers = owner.selectedAssetIdentifiers()
                    owner.photoKitService.deletePhotos(from: assetIdentifiers)
                        .bind { isSuccess in
                            if isSuccess {
                                owner.output.selectedRecordCells.accept([])
                            } else {
                                owner.output.alertPresented.accept(owner.removeFailedAlert)
                            }
                            owner.output.toggleLoading.accept(false)
                        }
                        .disposed(by: owner.disposeBag)
                }
            }
            .disposed(by: disposeBag)
        
        menuAction
            .bind(with: self) { owner, action in
                switch action {
                case .editAlbum:
                    owner.navigation.accept(.presentAlbumEdit(
                        owner.output.album.value,
                        owner.output.mediaFetchType.value,
                        owner.output.mediaFetchDetailType.value
                    ))
                    
                case .excludeRecord:
                    owner.navigation.accept(.presentExcludeRecord)
                }
            }
            .disposed(by: disposeBag)
        
        delegate
            .bind(with: self) { owner, delegate in
                switch delegate {
                case let .albumDidEdited(album, fetchType, detailType):
                    owner.output.album.accept(album)
                    owner.output.mediaFetchType.accept(fetchType)
                    owner.output.mediaFetchDetailType.accept(detailType)
                    owner.output.viewDidRefresh.accept(())
                    
                case .updateExcludeRecord:
                    owner.output.viewDidRefresh.accept(())
                }
            }
            .disposed(by: disposeBag)
        
        return output
    }
}

// MARK: - Helper

extension RecordViewModel {
    
    /// IndexPath에 대응되는 Asset Identifiers를 반환합니다.
    private func selectedAssetIdentifiers() -> [String] {
        output.selectedRecordCells.value.compactMap {
            output.mediaList.value[index(from: $0)].id
        }
    }
    
    /// 시작날짜를 기준으로 생성일이 몇일차인지 반환합니다.
    private func days(from creationDate: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents(
            [.day],
            from: calendar.startOfDay(for: output.album.value.trackingStartDate),
            to: calendar.startOfDay(for: creationDate)
        )
        return (components.day ?? 0) + 1
    }
    
    /// 날짜 별로 MediaList를 분리해 반환합니다.
    private func dayCountSections(from allMediaList: [Media]) -> SectionMediaList {
        var dic = [RecordSection: [Media]]()
        
        for media in allMediaList.sortedByCreationDate {
            guard let creationDate = media.creationDate else { continue }
            let days = days(from: creationDate)
            dic[.day(
                order: days,
                date: Calendar.current.startOfDay(for: creationDate)
            ), default: []].append(media)
        }
        
        return dic.keys
            .sorted(by: <)
            .map { ($0, dic[$0] ?? []) }
    }
    
    /// IndexPath의 Section과 Row를 기준으로 몇번째 인덱스인지 반환합니다.
    private func index(from indexPath: IndexPath) -> Int {
        var currentIndex = 0
        for (index, mediaList) in output.sectionMediaList.value.enumerated() {
            if index == indexPath.section {
                currentIndex += indexPath.row
                break
            }
            
            currentIndex += mediaList.1.count
        }
        return currentIndex
    }
    
    /// SectionMediaList의 전체 개수를 반환합니다.
    private func totalMediaCount() -> Int {
        var count = 0
        for (_, mediaList) in output.sectionMediaList.value {
            count += mediaList.count
        }
        return count
    }
}

// MARK: - Album Logic

extension RecordViewModel {
    
    /// 썸네일 없이 전체 Media 리스트를 반환합니다.
    ///
    /// - 제외된 사진을 필터링합니다.
    /// - 스크린샷이 제외되었을 때 필터링합니다.
    private func fetchAllMediaListWithNoThumbnail() -> [Media] {
        let trackingStartDate = output.album.value.trackingStartDate
        return photoKitService.fetchMediasWithNoThumbnail(
            mediaFetchType: .all,
            date: trackingStartDate,
            ascending: true
        )
        .filter { !Set(UserDefaultsService.excludeAssets).contains($0.id) }
        // TODO: 필터 로직 수정
//        .filter {
//            if !output.isContainScreenshot.value {
//                if case let .photo(isScreenshot) = $0.mediaType {
//                    return !isScreenshot
//                }
//            }
//            return true
//        }
    }
    
    /// 전체 Media 리스트를 반환합니다.
    private func fetchAllMediaList(from assetIdentifiers: [String]) -> Observable<[Media]> {
        photoKitService.fetchMedias(from: assetIdentifiers)
    }
}

// MARK: - Alert

extension RecordViewModel {
    
    /// 기록 없이 종료 Alert
    private var finishWithoutRecordAlert: AlertModel {
        AlertModel(
            title: "기록을 종료할까요?",
            message: "촬영된 기록이 없어 앨범 저장 없이 종료돼요",
            eventButton: .init(title: "종료") { [weak self] in
                self?.alertAction.accept(.finishWithoutRecord)
            },
            cancelButton: .init(title: "취소")
        )
    }
    
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

extension RecordViewModel {
    
    /// 앨범 제외 Action Sheet
    private var excludeActionSheet: ActionSheetModel {
        let title = output.album.value.title
        let selectedCount = output.selectedRecordCells.value.count
        return ActionSheetModel(
            message: "선택한 기록이 ‘\(title)’ 앨범에서 제외돼요. 나중에 언제든지 다시 추가할 수 있어요.",
            buttons: [
                .init(title: "\(selectedCount)장의 기록 앨범에서 제외", style: .default) { [weak self] in
                    self?.actionSheetAction.accept(.exclude)
                },
                .init(title: "취소", style: .cancel)
            ]
        )
    }
    
    /// 기록 삭제 Action Sheet
    private var removeActionSheet: ActionSheetModel {
        let selectedCount = output.selectedRecordCells.value.count
        return ActionSheetModel(
            message: "선택한 기록이 ‘사진’ 앱에서 삭제돼요. 삭제한 항목은 사진 앱의 ‘최근 삭제된 항목’에 30일간 보관돼요.",
            buttons: [
                .init(title: "\(selectedCount)장의 기록 삭제", style: .destructive) { [weak self] in
                    self?.actionSheetAction.accept(.remove)
                },
                .init(title: "취소", style: .cancel)
            ]
        )
    }
}

// MARK: - Menu

extension RecordViewModel {
    
    /// 더보기 Menu
    private var seemoreMenu: [MenuModel] {
        let editAlbum = MenuModel(symbol: .edit, title: "앨범 수정") { [weak self] in
            self?.menuAction.accept(.editAlbum)
        }
        let excludeRecord = MenuModel(symbol: .exclude, title: "제외된 기록") { [weak self] in
            self?.menuAction.accept(.excludeRecord)
        }
        return [editAlbum, excludeRecord]
    }
}
