//
//  SceneDelegate.swift
//  poporazzi
//
//  Created by 김민준 on 4/4/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = MomentTitleInputViewController()
        window?.makeKeyAndVisible()
    }
}
