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
            .bind(with: self) { owner, path in
                switch path {
                case .pushRecord(let album):
                    owner.pushRecord(titleInputVM, album)
                }
            }
            .disposed(by: titleInputVC.disposeBag)
        
        if UserDefaultsService.isTracking {
            let album = UserDefaultsService.record
            titleInputVM.navigation.accept(.pushRecord(album))
        }
        
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
}

// MARK: - Navigation Path

extension Coordinator {
    
    /// 기록 화면으로 Push 합니다.
    private func pushRecord(_ titleInputVM: TitleInputViewModel, _ album: Album) {
        let recordVM = RecordViewModel(output: .init(album: .init(value: album)))
        let recordVC = RecordViewController(viewModel: recordVM)
        self.navigationController.pushViewController(recordVC, animated: true)
        
        recordVM.navigation
            .bind(with: self) { owner, path in
                switch path {
                case .pop:
                    owner.navigationController.popViewController(animated: true)
                    
                case let .pushEdit(record):
                    owner.presentEdit(recordVM, record)
                }
            }
            .disposed(by: recordVC.disposeBag)
    }
}

// MARK: - Sheet

extension Coordinator {
    
    /// 기록 수정 화면을 Present 합니다.
    private func presentEdit(_ recordVM: RecordViewModel, _ album: Album) {
        let editVM = AlbumEditViewModel(
            output: .init(
                record: .init(value: album),
                titleText: .init(value: album.title),
                startDate: .init(value: album.trackingStartDate)
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
                    
                case .dismiss(let album):
                    recordVM.delegate.accept(.momentDidEdited(album))
                    editVC?.dismiss(animated: true)
                }
            }
            .disposed(by: editVC.disposeBag)
    }
    
    /// 날짜 선택 모달을 Present합니다.
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
}
