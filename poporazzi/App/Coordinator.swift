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
    private var mainViewModel: MainViewModel?
    
    init(window: UIWindow?) {
        self.window = window
    }
    
    /// 진입 화면을 설정합니다.
    func start() {
        let albumListVM = AlbumListViewModel(output: .init())
        let albumListVC = AlbumListViewController(viewModel: albumListVM)
        
        let albumId = UserDefaultsService.trackingAlbumId
        let selectedTab: Tab = albumId.isEmpty ? .albumList : .record(isTracking: true)
        var recordVMOutput = RecordViewModel.Output(record: .init(value: .initialValue))
        if !albumId.isEmpty {
            let album = persistenceService.readAlbum(fromId: albumId)
            recordVMOutput = .init(record: .init(value: album))
        }
        
        let recordVM = RecordViewModel(output: recordVMOutput)
        let recordVC = RecordViewController(viewModel: recordVM)
        
        let settingsVM = SettingsViewModel(output: .init())
        let settingsVC = SettingsViewController(viewModel: settingsVM)
        
        mainViewModel = MainViewModel(
            output: .init(
                selectedTab: .init(value: selectedTab),
                isTracking: .init(value: !albumId.isEmpty)
            )
        )
        
        guard let mainViewModel else { return }
        
        let mainVC = MainViewController(
            viewControllers: [albumListVC, recordVC, settingsVC],
            selectedTab: selectedTab,
            viewModel: mainViewModel
        )
        
        navigationController = UINavigationController(rootViewController: mainVC)
        navigationController.setNavigationBarHidden(true, animated: false)
        navigationController.delegate = self
        navigationController.interactivePopGestureRecognizer?.delegate = self
        
        mainViewModel.navigation
            .bind(with: self) { [weak albumListVM, weak recordVM] owner, path in
                switch path {
                case .presentTitleInput:
                    owner.presentTitleInput(recordVM)
                    
                case .presentAuthRequestModal:
                    owner.presentPermissionRequestModal(albumListVM)
                }
            }
            .disposed(by: mainVC.disposeBag)
        
        albumListVM.navigation
            .observe(on: MainScheduler.instance)
            .bind(with: self) { [weak albumListVM] owner, path in
                switch path {
                case .presentPermissionRequestModal:
                    owner.presentPermissionRequestModal(albumListVM)
                    
                case let .pushMyAlbum(album):
                    owner.pushMyAlbum(album)
                }
            }
            .disposed(by: mainVC.disposeBag)
        
        recordVM.navigation
            .observe(on: MainScheduler.instance)
            .bind(with: self) { [weak mainViewModel, weak recordVM] owner, path in
                switch path {
                case .finishRecord:
                    mainViewModel?.delegate.accept(.finishRecord)
                    
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
                    
                case let .toggleTabBar(bool):
                    mainViewModel?.delegate.accept(.toggleTabBar(bool))
                    
                case .presentPermissionRequestModal:
                    mainViewModel?.delegate.accept(.presentAuthRequestModal)
                    
                case let .pushDetail(album, initialImage, mediaList, selectedRow):
                    owner.presentDetail(recordVM, album, initialImage, mediaList, selectedRow)
                }
            }
            .disposed(by: recordVC.disposeBag)
        
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

// MARK: - Start Record Flow

extension Coordinator {
    
    /// 앨범 제목 입력 화면을 Present합니다.
    private func presentTitleInput(_ recordVM: RecordViewModel?) {
        let titleInputVM = TitleInputViewModel(output: .init())
        let titleInputVC = TitleInputViewController(viewModel: titleInputVM)
        
        let startRecordNavigation = UINavigationController(rootViewController: titleInputVC)
        startRecordNavigation.sheetPresentationController?.prefersGrabberVisible = true
        startRecordNavigation.setNavigationBarHidden(true, animated: false)
        startRecordNavigation.delegate = self
        startRecordNavigation.interactivePopGestureRecognizer?.delegate = self
        
        self.navigationController.present(startRecordNavigation, animated: true)
        
        titleInputVM.navigation
            .bind(with: self) { [weak titleInputVM, weak startRecordNavigation] owner, path in
                switch path {
                case let .pushAlbumOptionInput(title):
                    owner.pushAlbumOptionInput(titleInputVM, recordVM, startRecordNavigation, title)
                }
            }
            .disposed(by: titleInputVC.disposeBag)
    }
    
    /// 앨범 옵션 입력 화면으로 Push 합니다.
    private func pushAlbumOptionInput(
        _ titleInputVM: TitleInputViewModel?,
        _ recordVM: RecordViewModel?,
        _ startNavigation: UINavigationController?,
        _ title: String
    ) {
        let albumOptionVM = AlbumOptionInputViewModel(output: .init(titleText: .init(value: title)))
        let albumOptionVC = AlbumOptionInputViewController(viewModel: albumOptionVM)
        startNavigation?.pushViewController(albumOptionVC, animated: true)
        
        albumOptionVM.navigation
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, path in
                switch path {
                case .pop:
                    startNavigation?.popViewController(animated: true)
                    
                case let .startRecord(album):
                    owner.navigationController.dismiss(animated: true)
                    owner.mainViewModel?.delegate.accept(.startRecord)
                    recordVM?.delegate.accept(.startRecord(album))
                }
            }
            .disposed(by: albumOptionVC.disposeBag)
    }
}

// MARK: - Record Flow

extension Coordinator {
    
    /// 앨범 수정 화면을 Push 합니다.
    private func pushAlbumEdit(
        _ recordVM: RecordViewModel?,
        _ album: Record
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
    private func pushExcludeRecord(_ recordVM: RecordViewModel?, _ album: Record) {
        let excludeRecordVM = ExcludeRecordViewModel(output: .init(album: .init(value: album)))
        let excludeRecordVC = ExcludeRecordViewController(viewModel: excludeRecordVM)
        self.navigationController.pushViewController(excludeRecordVC, animated: true)
        
        excludeRecordVM.navigation
            .observe(on: MainScheduler.instance)
            .bind(with: self) { [weak excludeRecordVM] owner, path in
                switch path {
                case .pop:
                    owner.navigationController.popViewController(animated: true)
                    
                case let .updateRecord(album):
                    recordVM?.delegate.accept(.updateExcludeRecord(album))
                    
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
    
    /// 기록 종료 모달을 Present 합니다.
    private func presentFinishModal(_ recordVM: RecordViewModel?, album: Record, sectionMediaList: SectionMediaList) {
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
                    
                case .finishRecord:
                    owner.navigationController.dismiss(animated: true)
                    owner.mainViewModel?.delegate.accept(.finishRecord)
                }
            }
            .disposed(by: finishVC.disposeBag)
    }
    
    /// 상세보기 화면으로 Present 합니다.
    private func presentDetail(
        _ recordVM: RecordViewModel?,
        _ album: Record,
        _ initialImage: UIImage?,
        _ mediaList: [Media],
        _ selectedRow: Int
    ) {
        let detailVM = DetailViewModel(
            output: .init(
                album: .init(value: album),
                initialImage: .init(value: initialImage),
                initialRow: .init(value: selectedRow),
                currentRow: .init(value: selectedRow),
                mediaList: .init(value: mediaList)
            )
        )
        let detailVC = DetailViewController(viewModel: detailVM)
        detailVC.modalPresentationStyle = .overFullScreen
        self.navigationController.present(detailVC, animated: true)
        
        detailVM.navigation
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, path in
                switch path {
                case .dismiss:
                    owner.navigationController.dismiss(animated: true)
                    
                case let .updateRecord(album):
                    recordVM?.delegate.accept(.updateExcludeRecord(album))
                    
                case let .presentMediaShareSheet(shareItemList):
                    let activityController = UIActivityViewController(
                        activityItems: shareItemList,
                        applicationActivities: nil
                    )
                    owner.navigationController.present(activityController, animated: true)
                }
            }
            .disposed(by: detailVC.disposeBag)
    }
}

// MARK: - AlbumList Flow

extension Coordinator {
    
    /// MyAlbum 화면으로 Push 합니다.
    private func pushMyAlbum(_ album: Album) {
        let myAlbumVM = MyAlbumViewModel(output: .init(album: .init(value: album)))
        let myAlbumVC = MyAlbumViewController(viewModel: myAlbumVM)
        navigationController.pushViewController(myAlbumVC, animated: true)
        
        myAlbumVM.navigation
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, path in
                switch path {
                case .pop:
                    owner.navigationController.popViewController(animated: true)
                }
            }
            .disposed(by: myAlbumVC.disposeBag)
    }
}

// MARK: - Common Sheet

extension Coordinator {
    
    /// 사진 보관함 권한 요청 모달을 Present합니다.
    private func presentPermissionRequestModal(_ albumListVM: AlbumListViewModel?) {
        let permissionRequestVM = PermissionRequestModalViewModel(output: .init())
        let permissionRequestVC = PermissionRequestModalViewController(viewModel: permissionRequestVM)
        permissionRequestVC.isModalInPresentation = true
        permissionRequestVC.sheetPresentationController?.preferredCornerRadius = NameSpace.sheetRadius
        permissionRequestVC.sheetPresentationController?.detents = [.custom(resolver: { _ in 360 })]
        self.navigationController.present(permissionRequestVC, animated: true)
        
        permissionRequestVM.navigation
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, path in
                switch path {
                case .dismiss:
                    owner.navigationController.dismiss(animated: true)
                    albumListVM?.delegate.accept(.permissionAuthorized)
                }
            }
            .disposed(by: permissionRequestVC.disposeBag)
    }
    
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
}
