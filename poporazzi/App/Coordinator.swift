//
//  Coordinator.swift
//  poporazzi
//
//  Created by 김민준 on 4/28/25.
//

import UIKit
import RxSwift
import RxCocoa

final class Coordinator: NSObject {
    
    @Dependency(\.persistenceService) var persistenceService
    
    private var window: UIWindow?
    private var navigationController = UINavigationController()
    
    init(window: UIWindow?) {
        self.window = window
    }
    
    /// 진입 화면을 설정합니다.
    func start() {
        let titleInputVM = TitleInputViewModel(output: .init())
        let titleInputVC = TitleInputViewController(viewModel: titleInputVM)
        navigationController = UINavigationController(rootViewController: titleInputVC)
        navigationController.setNavigationBarHidden(true, animated: false)
        navigationController.delegate = self
        navigationController.interactivePopGestureRecognizer?.delegate = self
        
        titleInputVM.navigation
            .bind(with: self) { [weak titleInputVM] owner, path in
                switch path {
                case let .pushAlbumOptionInput(title):
                    owner.pushAlbumOptionInput(titleInputVM, title)
                    
                case let .pushRecord(album):
                    owner.pushRecord(album)
                }
            }
            .disposed(by: titleInputVC.disposeBag)
        
        let albumId = UserDefaultsService.trackingAlbumId
        if !albumId.isEmpty {
            let album = persistenceService.readAlbum(fromId: albumId)
            titleInputVM.navigation.accept(.pushRecord(album))
        }
        
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
}

// MARK: - PopGesture

extension Coordinator: UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    
    func navigationController(
        _ navigationController: UINavigationController,
        didShow viewController: UIViewController,
        animated: Bool
    ) {
        // RootViewController 비활성화
        guard navigationController.viewControllers.first !== viewController else {
            navigationController.interactivePopGestureRecognizer?.isEnabled = false
            return
        }
        
        if viewController is RecordViewController {
            navigationController.interactivePopGestureRecognizer?.isEnabled = false
        } else {
            navigationController.interactivePopGestureRecognizer?.isEnabled = true
        }
    }
}

// MARK: - Navigation Path

extension Coordinator {
    
    /// 앨범 옵션 입력 화면으로 Push 합니다.
    private func pushAlbumOptionInput(_ titleInputVM: TitleInputViewModel?, _ title: String) {
        let albumOptionVM = AlbumOptionInputViewModel(output: .init(titleText: .init(value: title)))
        let albumOptionVC = AlbumOptionInputViewController(viewModel: albumOptionVM)
        self.navigationController.pushViewController(albumOptionVC, animated: true)
        
        albumOptionVM.navigation
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, path in
                switch path {
                case .pop:
                    owner.navigationController.popViewController(animated: true)
                    
                case let .pushRecord(album):
                    owner.pushRecord(album)
                    titleInputVM?.delegate.accept(.reset)
                }
            }
            .disposed(by: albumOptionVC.disposeBag)
    }
    
    /// 기록 화면으로 Push 합니다.
    private func pushRecord(_ album: Album) {
        let recordVM = RecordViewModel(output: .init(album: .init(value: album)))
        let recordVC = RecordViewController(viewModel: recordVM)
        self.navigationController.pushViewController(recordVC, animated: true)
        
        recordVM.navigation
            .observe(on: MainScheduler.instance)
            .bind(with: self) { [weak recordVM] owner, path in
                switch path {
                case .pop:
                    owner.navigationController.popToRootViewController(animated: true)
                    
                case let .pushAlbumEdit(album):
                    owner.pushAlbumEdit(recordVM, album)
                    
                case let .presentExcludeRecord(album):
                    owner.pushExcludeRecord(recordVM, album)
                    
                case let .presentFinishModal(album, sectionMediaList):
                    owner.presentFinishModal(recordVM, album: album, sectionMediaList: sectionMediaList)
                    
                case let .presentMediaShareSheet(shareItemList):
                    let activityController = UIActivityViewController(
                        activityItems: shareItemList,
                        applicationActivities: nil
                    )
                    owner.navigationController.present(activityController, animated: true)
                    
                    activityController.completionWithItemsHandler = { _, isComplete, _, _ in
                        if isComplete {
                            recordVM?.delegate.accept(.completeSharing)
                        }
                    }
                }
            }
            .disposed(by: recordVC.disposeBag)
    }
    
    /// 앨범 수정 화면을 Push 합니다.
    private func pushAlbumEdit(
        _ recordVM: RecordViewModel?,
        _ album: Album
    ) {
        let editVM = AlbumEditViewModel(
            output: .init(
                album: .init(value: album),
                titleText: .init(value: album.title),
                startDate: .init(value: album.startDate),
                endDate: .init(value: album.endDate),
                mediaFetchOption: .init(value: album.mediaFetchOption),
                mediaFilterOption: .init(value: album.mediaFilterOption)
            )
        )
        let editVC = AlbumEditViewController(viewModel: editVM)
        self.navigationController.pushViewController(editVC, animated: true)
        
        editVM.navigation
            .observe(on: MainScheduler.instance)
            .bind(with: self) { [weak editVC] owner, path in
                switch path {
                case let .presentStartDatePicker(startDate, endDate):
                    owner.presentDatePickerModal(editVC, editVM, .startDate, startDate, endDate)
                    
                case let .presentEndDatePicker(startDate, endDate):
                    owner.presentDatePickerModal(editVC, editVM, .endDate, startDate, endDate)
                    
                case .pop:
                    owner.navigationController.popViewController(animated: true)
                    
                case let .dismissWithUpdate(album):
                    recordVM?.delegate.accept(.albumDidEdited(album))
                    owner.navigationController.popViewController(animated: true)
                }
            }
            .disposed(by: editVC.disposeBag)
    }
    
    /// 제외된 기록 화면을 Push 합니다.
    private func pushExcludeRecord(_ recordVM: RecordViewModel?, _ album: Album) {
        let excludeRecordVM = ExcludeRecordViewModel(output: .init(album: .init(value: album)))
        let excludeRecordVC = ExcludeRecordViewController(viewModel: excludeRecordVM)
        self.navigationController.pushViewController(excludeRecordVC, animated: true)
        
        excludeRecordVM.navigation
            .observe(on: MainScheduler.instance)
            .bind(with: self) { [weak excludeRecordVM] owner, path in
                switch path {
                case let .pop(album):
                    recordVM?.delegate.accept(.updateExcludeRecord(album))
                    owner.navigationController.popViewController(animated: true)
                    
                case let .presentMediaShareSheet(shareItemList):
                    let activityController = UIActivityViewController(
                        activityItems: shareItemList,
                        applicationActivities: nil
                    )
                    owner.navigationController.present(activityController, animated: true)
                    
                    activityController.completionWithItemsHandler = { _, isComplete, _, _ in
                        if isComplete {
                            excludeRecordVM?.delegate.accept(.completeSharing)
                        }
                    }
                }
            }
            .disposed(by: excludeRecordVC.disposeBag)
    }
}

// MARK: - Sheet

extension Coordinator {
    
    /// 날짜 선택 모달을 Present 합니다.
    private func presentDatePickerModal(
        _ editVC: AlbumEditViewController?,
        _ editVM: AlbumEditViewModel,
        _ modalState: DatePickerModalViewModel.ModalState,
        _ startDate: Date,
        _ endDate: Date?
    ) {
        let isEndofRecordActive: Bool = {
            switch modalState {
            case .startDate: return false
            case .endDate: return endDate == nil
            }
        }()
        
        let datePickerVM = DatePickerModalViewModel(
            output: .init(
                modalState: .init(value: modalState),
                startDate: .init(value: startDate),
                endDate: .init(value: endDate),
                isEndOfRecordActive: .init(value: isEndofRecordActive)
            )
        )
        let datePickerVC = DatePickerModalViewController(
            viewModel: datePickerVM,
            variation: modalState == .startDate ? .startDate : .endDate
        )
        datePickerVC.sheetPresentationController?.preferredCornerRadius = NameSpace.sheetRadius
        datePickerVC.sheetPresentationController?.prefersGrabberVisible = true
        editVC?.present(datePickerVC, animated: true)
        
        datePickerVM.navigation
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, path in
                switch path {
                case .pop:
                    editVC?.dismiss(animated: true)
                    
                case let .popFromStartDate(date):
                    editVM.delegate.accept(.startDateDidChanged(date))
                    editVC?.dismiss(animated: true)
                    
                case let .popFromEndDate(date):
                    editVM.delegate.accept(.endDateDidChanged(date))
                    editVC?.dismiss(animated: true)
                }
            }
            .disposed(by: datePickerVC.disposeBag)
    }
    
    /// 날짜 선택 모달을 Present 합니다.
    private func presentFinishModal(_ recordVM: RecordViewModel?, album: Album, sectionMediaList: SectionMediaList) {
        let finishVM = FinishConfirmModalViewModel(
            output: .init(
                album: .init(value: album),
                sectionMediaList: .init(value: sectionMediaList)
            )
        )
        let finishVC = FinishConfirmModalViewController(viewModel: finishVM)
        finishVC.sheetPresentationController?.preferredCornerRadius = NameSpace.sheetRadius
        finishVC.sheetPresentationController?.detents = [.custom(resolver: { _ in 340 })]
        finishVC.sheetPresentationController?.prefersGrabberVisible = true
        self.navigationController.present(finishVC, animated: true)
        
        finishVM.navigation
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, path in
                switch path {
                case .dismiss:
                    owner.navigationController.dismiss(animated: true)
                    
                case .popToRoot:
                    owner.navigationController.dismiss(animated: true)
                    owner.navigationController.popToRootViewController(animated: true)
                }
            }
            .disposed(by: finishVC.disposeBag)
    }
}
