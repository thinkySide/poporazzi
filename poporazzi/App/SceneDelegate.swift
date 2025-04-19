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
    var coordinator: AppCoordinator?
    
    private let sharedState = SharedState()
    private let disposeBag = DisposeBag()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        let navigationController = UINavigationController()
        coordinator = AppCoordinator(
            navigationController: navigationController,
            sharedState: sharedState
        )
        coordinator?.start()
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
    
    /// 백그라운드 진입 시 UserDefaults 업데이트
    func sceneDidEnterBackground(_ scene: UIScene) {
        UserDefaultsService.albumTitle = sharedState.record.value.title
        UserDefaultsService.trackingStartDate = sharedState.record.value.trackingStartDate
        UserDefaultsService.isTracking = sharedState.isTracking.value
    }
}
