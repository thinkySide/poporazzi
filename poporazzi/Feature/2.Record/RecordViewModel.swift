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
        let mediaList = BehaviorRelay<[Media]>(value: [])
        let setupInitialData = BehaviorRelay<[(Date, [Media])]>(value: [])
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
        case presentAlbumEdit(Album)
        case presentExcludeRecord
    }
    
    enum Delegate {
        case albumDidEdited(Album)
        case updateExcludeRecord
    }
    
    enum AlertAction {
        case save
        case linkToPhotoAlbum
        case popToHome
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
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .userInteractive))
            .bind(with: self) { owner, _ in
                owner.output.setupSeeMoreMenu.accept(owner.seemoreMenu)
                owner.output.mediaList.accept(owner.fetchAllMediaListWithNoThumbnail())
                
                let assetIdentifiers = owner.chunkAssetIdentifiers
                owner.requestImages(from: assetIdentifiers)
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
                guard indexPath.row <= owner.output.mediaList.value.count else { return }
                
                // 마지막 셀이 나타나기 전에 업데이트
                if indexPath.row >= (owner.currentChunk + owner.chunkSize - 10) {
                    owner.updateChunk()
                    let assetIdentifiers = owner.chunkAssetIdentifiers
                    
                    owner.requestImages(from: assetIdentifiers)
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
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .userInteractive))
            .bind(with: self) { owner, _ in
                owner.output.mediaList.accept(owner.fetchAllMediaListWithNoThumbnail())
                owner.resetChunk()
                
                let assetIdentifiers = owner.chunkAssetIdentifiers
                owner.requestImages(from: assetIdentifiers)
                    .bind { orderedMediaList in
                        owner.output.updateRecordCells.accept(orderedMediaList)
                    }
                    .disposed(by: owner.disposeBag)
            }
            .disposed(by: disposeBag)
        
        output.mediaList
            .bind(with: self) { owner, mediaList in
                owner.output.setupInitialData.accept(owner.dayCountSections(from: mediaList))
                owner.liveActivityService.update(
                    to: owner.output.album.value,
                    totalCount: mediaList.count
                )
            }
            .disposed(by: disposeBag)
        
        input.selectButtonTapped
            .map { true }
            .emit(to: output.switchSelectMode)
            .disposed(by: disposeBag)
        
        input.selectCancelButtonTapped
            .emit(with: self) { owner, _ in
                owner.output.selectedRecordCells.accept([])
                owner.output.switchSelectMode.accept(false)
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
            }
            .disposed(by: disposeBag)
        
        input.removeButtonTapped
            .emit(with: self) { owner, _ in
                owner.output.actionSheetPresented.accept(owner.removeActionSheet)
            }
            .disposed(by: disposeBag)
        
        input.finishButtonTapped
            .emit(with: self) { owner, _ in
                owner.output.alertPresented.accept(owner.finishConfirmAlert)
            }
            .disposed(by: disposeBag)
        
        alertAction
            .bind(with: self) { owner, action in
                switch action {
                case .save:
                    if owner.output.mediaList.value.isEmpty {
                        owner.navigation.accept(.pop)
                    } else {
                        try? owner.saveToAlbums()
                        owner.output.alertPresented.accept(owner.saveCompleteAlert)
                        HapticManager.notification(type: .success)
                    }
                    
                    owner.liveActivityService.stop()
                    UserDefaultsService.excludeAssets.removeAll()
                    UserDefaultsService.isTracking = false
                    
                case .linkToPhotoAlbum:
                    DeepLinkManager.openPhotoAlbum()
                    owner.navigation.accept(.pop)
                    break
                    
                case .popToHome:
                    owner.navigation.accept(.pop)
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
                    let album = owner.output.album.value
                    owner.navigation.accept(.presentAlbumEdit(album))
                    
                case .excludeRecord:
                    owner.navigation.accept(.presentExcludeRecord)
                }
            }
            .disposed(by: disposeBag)
        
        delegate
            .bind(with: self) { owner, delegate in
                switch delegate {
                case .albumDidEdited(let record):
                    owner.output.album.accept(record)
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
        output.selectedRecordCells.value.compactMap { output.mediaList.value[$0.row].id }
    }
    
    /// 날짜 별로 MediaList를 분리해 반환합니다.
    private func dayCountSections(from allMediaList: [Media]) -> [(Date, [Media])] {
        let calendar = Calendar.current
        var dic = [Date: [Media]]()
        
        for media in allMediaList.sortedByCreationDate {
            guard let creationDate = media.creationDate else { continue }
            let components = calendar.dateComponents([.year, .month, .day], from: creationDate)
            if let dayOnlyDate = calendar.date(from: components) {
                dic[dayOnlyDate, default: []].append(media)
            }
        }
        
        return dic.keys
            .sorted(by: <)
            .map { ($0, dic[$0] ?? []) }
    }
}

// MARK: - Album Logic

extension RecordViewModel {
    
    /// 썸네일 없이 전체 Media 리스트를 반환합니다.
    ///
    /// - 제외된 사진을 필터링합니다.
    private func fetchAllMediaListWithNoThumbnail() -> [Media] {
        let trackingStartDate = output.album.value.trackingStartDate
        return photoKitService.fetchMediasWithNoThumbnail(
            mediaFetchType: .all,
            date: trackingStartDate,
            ascending: true
        )
        .filter { media in
            !Set(UserDefaultsService.excludeAssets).contains(media.id)
        }
    }
    
    /// Asset Identifiers에 대응되는 Media 스트림을 반환합니다.
    private func requestImages(from assetIdentifiers: [String]) -> Observable<[Media]> {
        photoKitService.fetchMedias(from: assetIdentifiers)
    }
    
    /// 앨범에 저장합니다.
    private func saveToAlbums() throws {
        let title = output.album.value.title
        try photoKitService.saveAlbum(title: title, excludeAssets: UserDefaultsService.excludeAssets)
    }
}

// MARK: - Alert

extension RecordViewModel {
    
    /// 기록 종료 확인 Alert
    private var finishConfirmAlert: AlertModel {
        let title = output.album.value.title
        let totalCount = output.mediaList.value.count
        let message = output.mediaList.value.isEmpty
        ? "촬영된 기록이 없어 앨범 저장 없이 종료돼요"
        : "총 \(totalCount)장의 '\(title)' 기록이 종료 후 '사진' 앱 앨범에 저장돼요"
        return AlertModel(
            title: "기록을 종료할까요?",
            message: message,
            eventButton: .init(
                title: "종료",
                action: { [weak self] in
                    self?.alertAction.accept(.save)
                }
            ),
            cancelButton: .init(title: "취소")
        )
    }
    
    /// 앨범 저장 완료 Alert
    private var saveCompleteAlert: AlertModel {
        let title = output.album.value.title
        return AlertModel(
            title: "기록이 종료되었습니다!",
            message: "사진 앱 내 '\(title)' 앨범을 확인해보세요!",
            eventButton: .init(
                title: "앨범 확인",
                action: { [weak self] in
                    self?.alertAction.accept(.linkToPhotoAlbum)
                }
            ),
            cancelButton: .init(
                title: "홈으로 돌아가기",
                action: { [weak self] in
                    self?.alertAction.accept(.popToHome)
                }
            )
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
