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
    
    private let disposeBag = DisposeBag()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = MomentEditViewController()
        window?.makeKeyAndVisible()
        
//        if UserDefaultsService.isTracking {
//            presentMomentRecortViewController()
//        }
    }
}

// MARK: - Helper

extension SceneDelegate {
    
    private func presentMomentRecortViewController() {
        let momentRecordVC = MomentRecordViewController()
        momentRecordVC.modalPresentationStyle = .fullScreen
        momentRecordVC.modalTransitionStyle = .crossDissolve
        window?.rootViewController?.present(momentRecordVC, animated: true)
    }
}
