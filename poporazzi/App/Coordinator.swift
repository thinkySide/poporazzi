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
        
        titleInputVM.delegate.pushRecord
            .bind(with: self) { owner, _ in
                owner.pushRecord(titleInputVM)
            }
            .disposed(by: disposeBag)
        
        if UserDefaultsService.isTracking {
            let record = UserDefaultsService.record
            titleInputVM.delegate.pushRecord.accept((record))
        }
        
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
}

// MARK: - Navigation

extension Coordinator {
    
    private func pushRecord(_ titleInputVM: TitleInputViewModel) {
        let recordVM = RecordViewModel()
        let recordVC = RecordViewController(viewModel: recordVM)
        self.navigationController.pushViewController(recordVC, animated: true)
        
        recordVM.navigateToHome
            .bind(with: self) { owner, _ in
                owner.navigationController.popViewController(animated: true)
            }
            .disposed(by: self.disposeBag)
        
        recordVM.navigateToEdit
            .bind(with: self) { owner, _ in
                owner.presentEdit(recordVM)
            }
            .disposed(by: self.disposeBag)
    }
    
    private func presentEdit(_ recordVM: RecordViewModel) {
        let editVM = MomentEditViewModel()
        let editVC = MomentEditViewController(viewModel: editVM)
        self.navigationController.present(editVC, animated: true)
        
        editVM.dismiss
            .bind(with: self) { owner, record in
                recordVM.record.accept(record)
                editVC.dismiss(animated: true)
            }
            .disposed(by: self.disposeBag)
    }
}
