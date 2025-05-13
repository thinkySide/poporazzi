//
//  Coordinator.swift
//  poporazzi
//
//  Created by 김민준 on 4/28/25.
//

import UIKit
import RxSwift
import RxCocoa

final class Coordinator {
    
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
        
        titleInputVM.navigation
            .bind(with: self) { [weak titleInputVM] owner, path in
                switch path {
                case let .pushAlbumOptionInput(title):
                    owner.pushAlbumOptionInput(titleInputVM, title)
                    
                case let .pushRecord(album, fetchOption, filterOption):
                    owner.pushRecord(album, fetchOption, filterOption)
                }
            }
            .disposed(by: titleInputVC.disposeBag)
        
        let albumId = UserDefaultsService.trackingAlbumId
        if !albumId.isEmpty {
            let album = persistenceService.readAlbum(fromId: albumId)
            titleInputVM.navigation.accept(
                .pushRecord(
                    album,
                    album.mediaFetchOption,
                    album.mediaFilterOption
                )
            )
        }
        
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
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
            .bind(with: self) { owner, path in
                switch path {
                case .pop:
                    owner.navigationController.popViewController(animated: true)
                    
                case let .pushRecord(album, fetchOption, filterOption):
                    owner.pushRecord(album, fetchOption, filterOption)
                    titleInputVM?.delegate.accept(.reset)
                }
            }
            .disposed(by: albumOptionVC.disposeBag)
    }
    
    /// 기록 화면으로 Push 합니다.
    private func pushRecord(
        _ album: Album,
        _ fetchOption: MediaFetchOption,
        _ filterOption: MediaFilterOption
    ) {
        let recordVM = RecordViewModel(
            output: .init(
                album: .init(value: album),
                mediaFetchOption: .init(value: fetchOption),
                mediaFilterOption: .init(value: filterOption)
            )
        )
        let recordVC = RecordViewController(viewModel: recordVM)
        self.navigationController.pushViewController(recordVC, animated: true)
        
        recordVM.navigation
            .bind(with: self) { [weak recordVM] owner, path in
                switch path {
                case .pop:
                    owner.navigationController.popToRootViewController(animated: true)
                    
                case let .presentAlbumEdit(album, fetchType, detailFetchTypes):
                    owner.presentAlbumEdit(recordVM, album, fetchType, detailFetchTypes)
                    
                case let .presentExcludeRecord(excludeList):
                    owner.presentExcludeRecord(recordVM, excludeList)
                    
                case let .presentFinishModal(album, sectionMediaList):
                    owner.presentFinishModal(recordVM, album: album, sectionMediaList: sectionMediaList)
                }
            }
            .disposed(by: recordVC.disposeBag)
    }
}

// MARK: - Sheet

extension Coordinator {
    
    /// 앨범 수정 화면을 Present 합니다.
    private func presentAlbumEdit(
        _ recordVM: RecordViewModel?,
        _ album: Album,
        _ fetchOption: MediaFetchOption,
        _ filterOption: MediaFilterOption
    ) {
        let editVM = AlbumEditViewModel(
            output: .init(
                album: .init(value: album),
                titleText: .init(value: album.title),
                startDate: .init(value: album.startDate),
                mediaFetchOption: .init(value: fetchOption),
                mediaFilterOption: .init(value: filterOption)
            )
        )
        let editVC = AlbumEditViewController(viewModel: editVM)
        editVC.modalPresentationStyle = .overFullScreen
        self.navigationController.present(editVC, animated: true)
        
        editVM.navigation
            .bind(with: self) { [weak editVC] owner, path in
                switch path {
                case .presentStartDatePicker(let date):
                    owner.presentDatePickerModal(editVC, editVM, startDate: date)
                    
                case .dismiss:
                    editVC?.dismiss(animated: true)
                    
                case let .dismissWithUpdate(album, fetchType, detailFetchTypes):
                    recordVM?.delegate.accept(.albumDidEdited(album, fetchType, detailFetchTypes))
                    editVC?.dismiss(animated: true)
                }
            }
            .disposed(by: editVC.disposeBag)
    }
    
    /// 제외된 기록 화면을 Present 합니다.
    private func presentExcludeRecord(_ recordVM: RecordViewModel?, _ excludeList: Set<String>) {
        let excludeRecordVM = ExcludeRecordViewModel(output: .init(excludeList: .init(value: excludeList)))
        let excludeRecordVC = ExcludeRecordViewController(viewModel: excludeRecordVM)
        excludeRecordVC.modalPresentationStyle = .overFullScreen
        self.navigationController.present(excludeRecordVC, animated: true)
        
        excludeRecordVM.navigation
            .bind(with: self) { [weak excludeRecordVC] owner, path in
                switch path {
                case let .dismiss(newExcludeList):
                    recordVM?.delegate.accept(.updateExcludeRecord(excludeList: newExcludeList))
                    excludeRecordVC?.dismiss(animated: true)
                }
            }
            .disposed(by: excludeRecordVC.disposeBag)
    }
    
    /// 날짜 선택 모달을 Present 합니다.
    private func presentDatePickerModal(_ editVC: AlbumEditViewController?, _ editVM: AlbumEditViewModel, startDate: Date) {
        let datePickerVM = DatePickerModalViewModel(output: .init(selectedDate: .init(value: startDate)))
        let datePickerVC = DatePickerModalViewController(viewModel: datePickerVM)
        datePickerVC.sheetPresentationController?.preferredCornerRadius = 20
        datePickerVC.sheetPresentationController?.detents = [.custom(resolver: { _ in 300 })]
        datePickerVC.sheetPresentationController?.prefersGrabberVisible = true
        editVC?.present(datePickerVC, animated: true)
        
        datePickerVM.navigation
            .bind(with: self) { owner, path in
                switch path {
                case let .pop(date):
                    editVM.delegate.accept(.startDateDidChanged(date))
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
        finishVC.sheetPresentationController?.preferredCornerRadius = 20
        finishVC.sheetPresentationController?.detents = [.custom(resolver: { _ in 428 })]
        finishVC.sheetPresentationController?.prefersGrabberVisible = true
        self.navigationController.present(finishVC, animated: true)
        
        finishVM.navigation
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
