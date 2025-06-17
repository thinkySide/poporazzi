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
        let myAlbumListVM = MyAlbumListViewModel(output: .init())
        let myAlbumListVC = MyAlbumListViewController(viewModel: myAlbumListVM)
        
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
            viewControllers: [myAlbumListVC, recordVC, settingsVC],
            selectedTab: selectedTab,
            viewModel: mainViewModel
        )
        
        navigationController = UINavigationController(rootViewController: mainVC)
        navigationController.setNavigationBarHidden(true, animated: false)
        navigationController.delegate = self
        navigationController.interactivePopGestureRecognizer?.delegate = self
        
        mainViewModel.navigation
            .bind(with: self) { [weak navigationController, weak myAlbumListVM, weak recordVM] owner, path in
                switch path {
                case .presentTitleInput:
                    owner.presentTitleInput(recordVM)
                    
                case .presentAuthRequestModal:
                    owner.presentPermissionRequestModal(navigationController, myAlbumListVM)
                }
            }
            .disposed(by: mainVC.disposeBag)
        
        myAlbumListVM.navigation
            .observe(on: MainScheduler.instance)
            .bind(with: self) { [weak navigationController, weak myAlbumListVM] owner, path in
                switch path {
                case .presentPermissionRequestModal:
                    owner.presentPermissionRequestModal(navigationController, myAlbumListVM)
                    
                case let .pushFolderList(album):
                    owner.pushFolderList(myAlbumListVM, nil, album)
                    
                case let .pushAlbumDetail(album):
                    owner.pushAlbumDetail(myAlbumListVM, nil, album)
                }
            }
            .disposed(by: mainVC.disposeBag)
        
        recordVM.navigation
            .observe(on: MainScheduler.instance)
            .bind(with: self) { [weak mainViewModel, weak recordVM] owner, path in
                switch path {
                case .stopRecord:
                    owner.navigationController.dismiss(animated: true)
                    
                case let .finishRecord(record, mediaList, randomImageList):
                    owner.navigationController.dismiss(animated: true)
                    owner.pushCompleteRecord(record, mediaList, randomImageList)
                    
                case let .pushAlbumEdit(album):
                    owner.pushRecordEdit(recordVM, album)
                    
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
                    
                case let .presentDetail(record, initialImage, mediaList, selectedRow):
                    owner.presentMediaDetail(recordVM, .record(record), initialImage, mediaList, selectedRow)
                }
            }
            .disposed(by: recordVC.disposeBag)
        
        settingsVM.navigation
            .bind(with: self) { owner, path in
                switch path {
                case .pushOnboarding:
                    owner.pushOnboarding()
                    
                case let .presentShareSheet(shareItems):
                    let activityController = UIActivityViewController(
                        activityItems: shareItems,
                        applicationActivities: nil
                    )
                    owner.navigationController.present(activityController, animated: true)
                }
            }
            .disposed(by: settingsVM.disposeBag)
        
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
        if UserDefaultsService.isFirstLaunch {
            let onboardingVM = OnboardingViewModel(output: .init(isOnboarding: .init(value: true)))
            let onboardingVC = OnboardingViewController(viewModel: onboardingVM)
            onboardingVC.modalPresentationStyle = .overFullScreen
            self.navigationController.present(onboardingVC, animated: false)
            
            onboardingVM.navigation
                .bind(with: self) { [weak onboardingVC, weak myAlbumListVM] owner, path in
                    switch path {
                    case .presentPermissionRequestModal:
                        owner.presentPermissionRequestModal(onboardingVC, myAlbumListVM)
                        
                    default:
                        break
                    }
                }
                .disposed(by: onboardingVM.disposeBag)
        }
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
        
        // 제스처 비활성화 할 VC
        let disabledList = [
            RecordViewController.self,
            CompleteRecordViewController.self
        ]
        
        if disabledList.contains(where: { $0 == type(of: viewController) }) {
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
        let albumOptionVM = RecordOptionInputViewModel(output: .init(titleText: .init(value: title)))
        let albumOptionVC = RecordOptionInputViewController(viewModel: albumOptionVM)
        startNavigation?.pushViewController(albumOptionVC, animated: true)
        
        albumOptionVM.navigation
            .observe(on: MainScheduler.instance)
            .bind(with: self) { [weak startNavigation] owner, path in
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
    
    /// 기록 수정 화면을 Push 합니다.
    private func pushRecordEdit(
        _ recordVM: RecordViewModel?,
        _ record: Record
    ) {
        let editVM = RecordEditViewModel(
            output: .init(
                record: .init(value: record),
                titleText: .init(value: record.title),
                startDate: .init(value: record.startDate),
                endDate: .init(value: record.endDate),
                mediaFetchOption: .init(value: record.mediaFetchOption),
                mediaFilterOption: .init(value: record.mediaFilterOption)
            )
        )
        let editVC = RecordEditViewController(viewModel: editVM)
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
                record: .init(value: album),
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
                    recordVM?.delegate.accept(.finishRecord)
                }
            }
            .disposed(by: finishVC.disposeBag)
    }
    
    /// 상세보기 화면으로 Present 합니다.
    private func presentMediaDetail(
        _ recordVM: RecordViewModel?,
        _ dataType: DataType,
        _ initialImage: UIImage?,
        _ mediaList: [Media],
        _ selectedIndex: Int
    ) {
        let detailVM = MediaDetailViewModel(
            output: .init(
                dataType: .init(value: dataType),
                initialIndex: .init(value: selectedIndex),
                currentIndex: .init(value: selectedIndex),
                mediaList: .init(value: mediaList)
            )
        )
        let detailVC = MediaDetailViewController(
            viewModel: detailVM,
            initialIndex: selectedIndex,
            initialImage: initialImage
        )
        detailVC.modalPresentationStyle = .overFullScreen
        self.navigationController.present(detailVC, animated: true)
        
        detailVM.navigation
            .observe(on: MainScheduler.instance)
            .bind(with: self) { [weak detailVC] owner, path in
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
                    detailVC?.present(activityController, animated: true)
                }
            }
            .disposed(by: detailVM.disposeBag)
    }
    
    /// 기록 완료 화면으로 Push 합니다.
    private func pushCompleteRecord(
        _ record: Record,
        _ mediaList: [Media],
        _ randomImageList: [UIImage]
    ) {
        let completeRecordVM = CompleteRecordViewModel(
            output: .init(
                record: .init(value: record),
                mediaList: .init(value: mediaList),
                randomImageList: .init(value: randomImageList)
            )
        )
        let completeRecrodVC = CompleteRecordViewController(viewModel: completeRecordVM)
        self.navigationController.pushViewController(completeRecrodVC, animated: true)
        
        completeRecordVM.navigation
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, path in
                switch path {
                case .completeRecord:
                    owner.navigationController.popToRootViewController(animated: true)
                    owner.mainViewModel?.delegate.accept(.finishRecord)
                    
                case let .presentMediaShareSheet(shareItemList):
                    let activityController = UIActivityViewController(
                        activityItems: shareItemList,
                        applicationActivities: nil
                    )
                    owner.navigationController.present(activityController, animated: true)
                }
            }
            .disposed(by: completeRecordVM.disposeBag)
    }
}

// MARK: - My Album List Flow

extension Coordinator {
    
    /// 앨범 상세보기 화면으로 Push 합니다.
    private func pushAlbumDetail(
        _ myAlbumListVM: MyAlbumListViewModel?,
        _ folderListVM: FolderListViewModel?,
        _ album: Album
    ) {
        let albumDetailVM = AlbumDetailViewModel(output: .init(album: .init(value: album)))
        let albumDetailVC = AlbumDetailViewController(viewModel: albumDetailVM)
        navigationController.pushViewController(albumDetailVC, animated: true)
        
        albumDetailVM.navigation
            .observe(on: MainScheduler.instance)
            .bind(with: self) {
                [weak myAlbumListVM, weak albumDetailVC, weak albumDetailVM] owner, path in
                switch path {
                case .viewWillDisappear:
                    folderListVM?.delegate.accept(.viewDidRefresh)
                    myAlbumListVM?.delegate.accept(.viewDidRefresh)
                    
                case let .pushAlbumEdit(album):
                    owner.pushAlbumEdit(albumDetailVM, album)
                    
                case .pop:
                    folderListVM?.delegate.accept(.viewDidRefresh)
                    myAlbumListVM?.delegate.accept(.viewDidRefresh)
                    owner.navigationController.popViewController(animated: true)
                    
                case let .presentDetail(album, image, mediaList, selectedIndex):
                    owner.presentMediaDetail(nil, .album(album), image, mediaList, selectedIndex)
                    
                case let .presentMediaShareSheet(shareItemList):
                    let activityController = UIActivityViewController(
                        activityItems: shareItemList,
                        applicationActivities: nil
                    )
                    albumDetailVC?.present(activityController, animated: true)
                }
            }
            .disposed(by: albumDetailVM.disposeBag)
    }
    
    /// 폴더 리스트 화면으로 Push 합니다.
    private func pushFolderList(
        _ myAlbumListVM: MyAlbumListViewModel?,
        _ newFolderListVM: FolderListViewModel?,
        _ album: Album
    ) {
        let folderListVM = FolderListViewModel(output: .init(folder: .init(value: album)))
        let folderListVC = FolderListViewController(viewModel: folderListVM)
        navigationController.pushViewController(folderListVC, animated: true)
        
        folderListVM.navigation
            .bind(with: self) { [weak newFolderListVM, weak folderListVM] owner, path in
                switch path {
                case .viewWillDisappear:
                    newFolderListVM?.delegate.accept(.viewDidRefresh)
                    myAlbumListVM?.delegate.accept(.viewDidRefresh)
                    
                case .pop:
                    newFolderListVM?.delegate.accept(.viewDidRefresh)
                    myAlbumListVM?.delegate.accept(.viewDidRefresh)
                    owner.navigationController.popViewController(animated: true)
                    
                case let .pushFolderList(album):
                    owner.pushFolderList(myAlbumListVM, folderListVM, album)
                    
                case let .pushFolderEdit(folder):
                    owner.pushFolderEdit(folderListVM, folder)
                    
                case let .pushAlbumDetail(album):
                    owner.pushAlbumDetail(myAlbumListVM, folderListVM, album)
                }
            }
            .disposed(by: folderListVM.disposeBag)
    }
    
    /// 폴더 수정 화면으로 Push 합니다.
    private func pushFolderEdit(
        _ folderListVM: FolderListViewModel?,
        _ folder: Album
    ) {
        let folderEditVM = FolderEditViewModel(
            output: .init(
                folder: .init(value: folder),
                titleText: .init(value: folder.title)
            )
        )
        let folderEditVC = FolderEditViewController(viewModel: folderEditVM)
        navigationController.pushViewController(folderEditVC, animated: true)
        
        folderEditVM.navigation
            .bind(with: self) { owner, path in
                switch path {
                case .pop:
                    owner.navigationController.popViewController(animated: true)
                    
                case let .popWithUpdate(folder):
                    owner.navigationController.popViewController(animated: true)
                    folderListVM?.delegate.accept(.folderWillUpdate(folder))
                }
            }
            .disposed(by: folderEditVM.disposeBag)
    }
    
    /// 앨범 수정 화면으로 Push 합니다.
    private func pushAlbumEdit(
        _ albumDetailVM: AlbumDetailViewModel?,
        _ album: Album
    ) {
        let albumEditVM = AlbumEditViewModel(
            output: .init(
                album: .init(value: album),
                titleText: .init(value: album.title)
            )
        )
        let albumEditVC = AlbumEditViewController(viewModel: albumEditVM)
        navigationController.pushViewController(albumEditVC, animated: true)
        
        albumEditVM.navigation
            .bind(with: self) { owner, path in
                switch path {
                case .pop:
                    owner.navigationController.popViewController(animated: true)
                    
                case let .popWithUpdate(newAlbum):
                    owner.navigationController.popViewController(animated: true)
                    albumDetailVM?.delegate.accept(.albumWillUpdate(newAlbum))
                }
            }
            .disposed(by: albumEditVM.disposeBag)
    }
}

// MARK: - Settings Flow

extension Coordinator {
    
    /// 온보딩 화면으로 Push합니다.
    private func pushOnboarding() {
        let onboardingVM = OnboardingViewModel(output: .init(isOnboarding: .init(value: false)))
        let onboardingVC = OnboardingViewController(viewModel: onboardingVM)
        self.navigationController.pushViewController(onboardingVC, animated: true)
        
        onboardingVM.navigation
            .bind(with: self) { owner, path in
                switch path {
                case .pop:
                    owner.navigationController.popViewController(animated: true)
                    
                default:
                    break
                }
            }
            .disposed(by: onboardingVM.disposeBag)
    }
}

// MARK: - Common Sheet

extension Coordinator {
    
    /// 사진 보관함 권한 요청 모달을 Present합니다.
    private func presentPermissionRequestModal(_ rootViewController: UIViewController?, _ myAlbumListVM: MyAlbumListViewModel?) {
        let permissionRequestVM = PermissionRequestModalViewModel(output: .init())
        let permissionRequestVC = PermissionRequestModalViewController(viewModel: permissionRequestVM)
        permissionRequestVC.isModalInPresentation = true
        permissionRequestVC.sheetPresentationController?.preferredCornerRadius = NameSpace.sheetRadius
        permissionRequestVC.sheetPresentationController?.detents = [.custom(resolver: { _ in 360 })]
        rootViewController?.present(permissionRequestVC, animated: true)
        
        permissionRequestVM.navigation
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, path in
                switch path {
                case .dismiss:
                    owner.navigationController.dismiss(animated: true)
                    myAlbumListVM?.delegate.accept(.permissionAuthorized)
                }
            }
            .disposed(by: permissionRequestVC.disposeBag)
    }
    
    /// 날짜 선택 모달을 Present 합니다.
    private func presentDatePickerModal(
        _ editVC: RecordEditViewController?,
        _ editVM: RecordEditViewModel,
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
