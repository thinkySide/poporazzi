//
//  DeepLinkManager.swift
//  poporazzi
//
//  Created by 김민준 on 5/7/25.
//

import UIKit

/// DeepLink 관리용
enum DeepLinkManager {
    
    /// 기본 앱스토어 링크
    static let appStoreLink = "https://apps.apple.com/app/id\(NameSpace.appleId)"
    
    /// 사진 앱의 앨범으로 딥링크합니다.
    static func openPhotoAlbum() {
        if let url = URL(string: "photos-navigation://album?name=recents") {
            UIApplication.shared.open(url)
        }
    }
    
    /// 설정 앱으로 딥링크합니다.
    static func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
    
    /// 앱스토어 리뷰 페이지로 딥링크합니다.
    static func openAppStoreReview() {
        if let url = URL(string: "\(appStoreLink)?action=write-review") {
            UIApplication.shared.open(url)
        }
    }
    
    /// 문의 링크로 딥링크합니다.
    static func openInquiryLink() {
        if let url = URL(string: "https://open.kakao.com/o/s6CeCuzh") {
            UIApplication.shared.open(url)
        }
    }
}
