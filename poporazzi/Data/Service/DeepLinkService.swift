//
//  DeepLinkService.swift
//  poporazzi
//
//  Created by 김민준 on 5/7/25.
//

import UIKit

struct DeepLinkService {
    
    /// 사진 앱의 앨범으로 딥링크합니다.
    static func openPhotoAlbum() {
        if let url = URL(string: "photos-navigation://album?name=recents") {
            UIApplication.shared.open(url)
        }
    }
}
