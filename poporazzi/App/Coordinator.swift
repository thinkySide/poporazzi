//
//  Coordinator.swift
//  poporazzi
//
//  Created by 김민준 on 4/28/25.
//

import UIKit
import RxSwift

final class Coordinator {
    
    private var window: UIWindow?
    private var navigationController = UINavigationController()
    private let disposeBag = DisposeBag()
    
    init(window: UIWindow?) {
        self.window = window
    }
    
    /// 진입 화면을 설정합니다.
    func start() {
        let titleInputVM = TitleInputViewModel()
        let titleInputVC = TitleInputViewController(viewModel: titleInputVM)
        navigationController = UINavigationController(rootViewController: titleInputVC)
        navigationController.setNavigationBarHidden(true, animated: false)
        
        titleInputVM.navigation.pushRecord
            .bind(with: self) { owner, record in
                owner.pushRecord(titleInputVM, record)
            }
            .disposed(by: disposeBag)
        
        if UserDefaultsService.isTracking {
            let record = UserDefaultsService.record
            titleInputVM.navigation.pushRecord.accept((record))
        }
        
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
}

// MARK: - Navigation

extension Coordinator {
    
    private func pushRecord(_ titleInputVM: TitleInputViewModel, _ record: Record) {
        let recordVM = RecordViewModel(record: record)
        let recordVC = RecordViewController(viewModel: recordVM)
        self.navigationController.pushViewController(recordVC, animated: true)
        
        recordVM.navigation.pop
            .bind(with: self) { owner, _ in
                owner.navigationController.popViewController(animated: true)
            }
            .disposed(by: self.disposeBag)
        
        recordVM.navigation.pushEdit
            .bind(with: self) { owner, record in
                owner.presentEdit(recordVM, record)
            }
            .disposed(by: self.disposeBag)
    }
    
    private func presentEdit(_ recordVM: RecordViewModel, _ record: Record) {
        let editVM = MomentEditViewModel(record: record)
        let editVC = MomentEditViewController(viewModel: editVM)
        editVC.modalPresentationStyle = .overFullScreen
        self.navigationController.present(editVC, animated: true)
        
        editVM.navigation.dismiss
            .bind(with: self) { owner, record in
                recordVM.delegate.editedRecord.accept(record)
                editVC.dismiss(animated: true)
            }
            .disposed(by: self.disposeBag)
    }
}
