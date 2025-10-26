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

        // Universal Link 처리 (앱이 실행되지 않은 상태)
        if let userActivity = connectionOptions.userActivities.first {
            handleUniversalLink(userActivity)
        }
    }

    // Universal Link 처리 (앱이 이미 실행 중일 때)
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        handleUniversalLink(userActivity)
    }

    private func handleUniversalLink(_ userActivity: NSUserActivity) {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let url = userActivity.webpageURL else {
            return
        }

        print("🔗 Universal Link Received")
        print("Full URL: \(url.absoluteString)")
        print("Scheme: \(url.scheme ?? "")")
        print("Host: \(url.host ?? "")")
        print("Path: \(url.path)")
        print("Query: \(url.query ?? "")")
    }
}
