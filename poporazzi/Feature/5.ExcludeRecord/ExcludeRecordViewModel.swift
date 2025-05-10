//
//  ExcludeRecordViewModel.swift
//  poporazzi
//
//  Created by 김민준 on 5/5/25.
//

import Foundation
import RxSwift
import RxCocoa

final class ExcludeRecordViewModel: ViewModel {
    
    @Dependency(\.photoKitService) private var photoKitService
    
    let disposeBag = DisposeBag()
    
    private let output: Output
    
    let navigation = PublishRelay<Navigation>()
    let actionSheetAction = PublishRelay<ActionSheetAction>()
    
    init(output: Output) {
        self.output = output
    }
    
    deinit {
        Log.print(#file, .deinit)
    }
}

// MARK: - Input & Output

extension ExcludeRecordViewModel {
    
    struct Input {
        let viewDidLoad: Signal<Void>
        let backButtonTapped: Signal<Void>
        let selectButtonTapped: Signal<Void>
        let selectCancelButtonTapped: Signal<Void>
        let recordCellSelected: Signal<IndexPath>
        let recordCellDeselected: Signal<IndexPath>
        let recoverButtonTapped: Signal<Void>
        let removeButtonTapped: Signal<Void>
    }
    
    struct Output {
        let mediaList = BehaviorRelay<[Media]>(value: [])
        let selectedRecordCells = BehaviorRelay<[IndexPath]>(value: [])
        let switchSelectMode = PublishRelay<Bool>()
        let viewDidRefresh = PublishRelay<Void>()
        let alertPresented = PublishRelay<AlertModel>()
        let actionSheetPresented = PublishRelay<ActionSheetModel>()
        let toggleLoading = PublishRelay<Bool>()
    }
    
    enum Navigation {
        case dismiss
    }
    
    enum ActionSheetAction {
        case recover
        case remove
    }
}

// MARK: - Transform

extension ExcludeRecordViewModel {
    
    func transform(_ input: Input) -> Output {
        Signal.merge(input.viewDidLoad, output.viewDidRefresh.asSignal())
            .asObservable()
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .userInteractive))
            .withUnretained(self)
            .flatMap { owner, _ in owner.fetchExcludePhotos() }
            .bind(with: self) { owner, mediaList in
                owner.output.mediaList.accept(mediaList)
            }
            .disposed(by: disposeBag)
        
        input.backButtonTapped
            .emit(with: self) { owner, _ in
                owner.navigation.accept(.dismiss)
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
        
        input.recoverButtonTapped
            .emit(with: self) { owner, _ in
                owner.output.actionSheetPresented.accept(owner.recoverActionSheet)
            }
            .disposed(by: disposeBag)
        
        input.removeButtonTapped
            .emit(with: self) { owner, _ in
                owner.output.actionSheetPresented.accept(owner.removeActionSheet)
            }
            .disposed(by: disposeBag)
        
        actionSheetAction
            .bind(with: self) { owner, action in
                switch action {
                case .recover:
                    let assetIdentifiers = owner.selectedAssetIdentifiers()
                    UserDefaultsService.excludeAssets.removeAll { assetIdentifiers.contains($0) }
                    owner.output.viewDidRefresh.accept(())
                    owner.output.selectedRecordCells.accept([])
                    
                case .remove:
                    owner.output.toggleLoading.accept(true)
                    let assetIdentifiers = owner.selectedAssetIdentifiers()
                    owner.photoKitService.deletePhotos(from: assetIdentifiers)
                        .bind { isSuccess in
                            if isSuccess {
                                UserDefaultsService.excludeAssets.removeAll { assetIdentifiers.contains($0) }
                                owner.output.viewDidRefresh.accept(())
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
        
        return output
    }
}

// MARK: - Helper

extension ExcludeRecordViewModel {

    /// IndexPath에 대응되는 Asset Identifiers를 반환합니다.
    private func selectedAssetIdentifiers() -> [String] {
        output.selectedRecordCells.value.compactMap { output.mediaList.value[$0.row].id }
    }
}

// MARK: - PhotoKit Logic

extension ExcludeRecordViewModel {
    
    /// 제외된 사진을 반환합니다.
    private func fetchExcludePhotos() -> Observable<[Media]> {
        let assetIdentifiers = UserDefaultsService.excludeAssets
        return photoKitService.fetchMedias(from: assetIdentifiers)
    }
}

// MARK: - Alert

extension ExcludeRecordViewModel {
    
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

extension ExcludeRecordViewModel {
    
    /// 앨범으로 복구 Action Sheet
    private var recoverActionSheet: ActionSheetModel {
        let selectedCount = output.selectedRecordCells.value.count
        return ActionSheetModel(
            buttons: [
                .init(title: "\(selectedCount)장의 기록 앨범으로 복구", style: .default) { [weak self] in
                    self?.actionSheetAction.accept(.recover)
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
