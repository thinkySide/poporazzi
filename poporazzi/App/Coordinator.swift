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
    private let disposeBag = DisposeBag()
    
    init(window: UIWindow?) {
        self.window = window
    }
    
    /// 진입 화면을 설정합니다.
    func start() {
        let titleInputVM = TitleInputViewModel(state: .init())
        let titleInputVC = TitleInputViewController(viewModel: titleInputVM)
        navigationController = UINavigationController(rootViewController: titleInputVC)
        navigationController.setNavigationBarHidden(true, animated: false)
        
        titleInputVM.navigation
            .bind(with: self) { owner, navigation in
                switch navigation {
                case .pushRecord(let record):
                    owner.pushRecord(titleInputVM, record)
                }
            }
            .disposed(by: disposeBag)
        
        if UserDefaultsService.isTracking {
            let record = UserDefaultsService.record
            titleInputVM.navigation.accept(.pushRecord(record))
        }
        
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
}

// MARK: - Navigation

extension Coordinator {
    
    private func pushRecord(_ titleInputVM: TitleInputViewModel, _ record: Record) {
        let recordVM = RecordViewModel(state: .init(record: .init(value: record)))
        let recordVC = RecordViewController(viewModel: recordVM)
        self.navigationController.pushViewController(recordVC, animated: true)
        
        recordVM.navigation
            .bind(with: self) { owner, navigation in
                switch navigation {
                case .pop:
                    owner.navigationController.popViewController(animated: true)
                    
                case .pushEdit(let record):
                    owner.presentEdit(recordVM, record)
                }
            }
            .disposed(by: disposeBag)
    }
    
    private func presentEdit(_ recordVM: RecordViewModel, _ record: Record) {
        let editVM = MomentEditViewModel(
            state: .init(
                record: .init(value: record),
                titleText: .init(value: record.title)
            )
        )
        let editVC = MomentEditViewController(viewModel: editVM)
        editVC.modalPresentationStyle = .overFullScreen
        self.navigationController.present(editVC, animated: true)
        
        editVM.navigation.dismiss
            .bind(with: self) { owner, record in
                recordVM.delegate.accept(.editComplete(record))
                editVC.dismiss(animated: true)
            }
            .disposed(by: self.disposeBag)
    }
}
