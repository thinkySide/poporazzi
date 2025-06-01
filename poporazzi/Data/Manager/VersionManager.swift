//
//  VersionManager.swift
//  poporazzi
//
//  Created by 김민준 on 5/3/25.
//

import UIKit
import RxSwift

/// 버전 관리용
enum VersionManager {
    
    /// 각 URLString을 저장하는 열거형
    enum URLString {
        case version
        case appStore
        
        /// 각 URLString을 반환합니다.
        var value: String {
            switch self {
            case .version: "http://itunes.apple.com/lookup?id=\(NameSpace.appleId)"
            case .appStore: "itms-apps://itunes.apple.com/app/apple-store/\(NameSpace.appleId)"
            }
        }
    }
    
    /// VersionService에 발생할 수 있는 에러
    enum VersionError: Error {
        case urlSessionError
    }
}

// MARK: - Use Case

extension VersionManager {
    
    /// 현재 디바이스에 설치된 버전을 반환합니다.
    static var deviceAppVersion: String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
    }
    
    /// 앱스토어 내 최신 버전을 반환합니다.
    static var appStoreAppVersion: Observable<String> {
        guard let url = URL(string: URLString.version.value) else { return .never() }
        
        return Observable.create { observer in
            URLSession.shared.dataTask(with: url) { data, _, _ in
                guard let data,
                      let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any],
                      let results = json["results"] as? [[String: Any]],
                      let appStoreVersion = results[0]["version"] as? String else {
                    observer.onError(VersionError.urlSessionError)
                    return
                }
                observer.onNext(appStoreVersion)
                observer.onCompleted()
            }
            .resume()
            
            return Disposables.create()
        }
    }
    
    /// 앱스토어를 Open합니다.
    static func openAppStore() {
        guard let url = URL(string: URLString.appStore.value) else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
