//
//  SceneDelegate.swift
//  poporazzi
//
//  Created by 김민준 on 4/4/25.
//

import UIKit
import RxSwift

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    var coordinator: Coordinator?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        coordinator = Coordinator(window: window)
        coordinator?.start()
    }
}

final class Coordinator {
    
    private var window: UIWindow?
    private var navigationController = UINavigationController()
    private let disposeBag = DisposeBag()
    
    init(window: UIWindow?) {
        self.window = window
    }
    
    func start() {
        let titleInputVM = TitleInputViewModel()
        let titleInputVC = TitleInputViewController(viewModel: titleInputVM)
        navigationController = UINavigationController(rootViewController: titleInputVC)
        navigationController.setNavigationBarHidden(true, animated: false)
        
        titleInputVM.navigateToRecord
            .subscribe { _ in
                let recordVM = RecordViewModel()
                let recordVC = RecordViewController(viewModel: recordVM)
                self.navigationController.pushViewController(recordVC, animated: true)
                
                recordVM.navigateToHome
                    .subscribe { _ in
                        self.navigationController.popViewController(animated: true)
                    }
                    .disposed(by: self.disposeBag)
                
                recordVM.navigateToEdit
                    .subscribe { _ in
                        let editVM = MomentEditViewModel()
                        let editVC = MomentEditViewController(viewModel: editVM)
                        self.navigationController.present(editVC, animated: true)
                        
                        editVM.dismiss
                            .bind(with: self, onNext: { asd, record in
                                recordVM.record.accept(record)
                            })
                            .disposed(by: self.disposeBag)
                    }
                    .disposed(by: self.disposeBag)
            }
            .disposed(by: disposeBag)
        
        if UserDefaultsService.isTracking {
            titleInputVM.navigateToRecord.accept(())
        }
        
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
}
